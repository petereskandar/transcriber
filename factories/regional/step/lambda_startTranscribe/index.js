const AWS = require('aws-sdk');

exports.handler = async (event) => {
    var region = 'eu-west-3';
    var s3bucket = event['Input']['Bucket'];
    var s3object = event['Input']['Key'];

    const transcribe = new AWS.TranscribeService(region);
    const s3 = new AWS.S3(region);
    
    // Start Transcribe job
    const params = {
        TranscriptionJobName: s3bucket + '_' + Math.floor(Math.random() * 101),
        IdentifyLanguage: true,
        LanguageOptions: ["en-US", "es-US", "fr-FR", "it-IT"],
        MediaFormat: s3object.split('.')[1].toLowerCase(),
        Media:{
            MediaFileUri : `https://s3-eu-west-3.amazonaws.com/${s3bucket}/${s3object}`
        }
    }
    const response = await new Promise((resolve, reject) => {
      transcribe.startTranscriptionJob(params, function(err, data) {
            if(err) reject(err); // an error occurred
            else    resolve(data);           // successful response
        });  
    });
    
    // get S3Object tags --> email
    const s3Params = {
        Bucket: s3bucket, 
        Key: s3object
    }
    
    const tagsList = await new Promise((resolve, reject)  => {
         s3.getObjectTagging(s3Params, function(err, data) {
                if(err) reject(err);  // an error occurred
                else    resolve(data);  // successful response
         });
    })
    
    return {
        Email: tagsList['TagSet'][0]['Value'],
        TranscriptionJobName: response['TranscriptionJob']['TranscriptionJobName']
    }    
};
