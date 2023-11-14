const AWS = require('aws-sdk');
const https = require('https');
const assert = require('assert');

exports.handler = async (event) => {
    
    // required params
    let region = process.env.REGION;
    let payload = event['Input']['Payload']
    let transcriptFileUri = payload['TranscriptFileUri'];
    let transcriptionJobName = payload['TranscriptionJobName'];
    let transcriptionJobStatus = payload['TranscriptionJobStatus'];
    let userEmail = payload['Email'];
    
    const transcribe = new AWS.TranscribeService(region);
    // sns notifications
    const ses = new AWS.SES({ region: region });

    // donwload generated file by Transcribe from s3
    const transcription = transcriptFileUri !== 'none' ? await new Promise((resolve, reject) => {
        const req = https.get(transcriptFileUri, function(res) {
          var dataString = '';
          res.on('data', chunk => {
            dataString += chunk;
          });
          res.on('end', () => {
            resolve({
                body: dataString ? JSON.parse(dataString)["results"]["transcripts"][0]['transcript'] : 'No response'
            });
          });
        });
        
        req.on('error', (e) => {
          reject({
              statusCode: 500,
              body: 'Something went wrong!'
          });
        });
    }) : { body: 'unable to process file' };
    
    // delete current job after completion
    const params = {
        TranscriptionJobName: transcriptionJobName
    }
    const response = await new Promise((resolve, reject) => {
      transcribe.deleteTranscriptionJob(params, function(err, data) {
            if(err) reject(err);    // an error occurred
            else    resolve(data);  // successful response
        });  
    });
    
    // send AWS SNS Notifications
    const sendNotificationEmail = function(msg) {
      var params = {
        Destination: {
          ToAddresses: [userEmail],
        },
        Message: {
          Body: {
            Text: { Data: msg['body'] },
          },
    
          Subject: { Data: "Audio Converter" },
        },
        Source: process.env.SENDER_EMAIL,
      };
    
      return new Promise((resolve, reject) => {
        ses.sendEmail(params, (err, data) => {
          if(err) reject(err);
          else resolve(data);
        })
      });
    }
    
    // send data via mail
    await sendNotificationEmail(transcription);
    return {
        response: transcription,
        TranscriptFileUri: transcriptFileUri,
        TranscriptionJobName: transcriptionJobName,
        TranscriptionJobStatus: transcriptionJobStatus
    }
};

