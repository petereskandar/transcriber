const AWS = require('aws-sdk');

exports.handler = async (event) => {
    // Set your AWS region
    let region = process.env.REGION;

    // Set the Transcribe service object
    const transcribe = new AWS.TranscribeService({ region });

    let payload = event['Input']['Payload']
    let transcriptionJobName = payload['TranscriptionJobName']
    let userEmail = payload['Email']

    // Set the parameters for the getTranscriptionJob operation
    const params = {
        TranscriptionJobName: transcriptionJobName
    };

    try {
        // Call the getTranscriptionJob operation to get the job status
        const response = await transcribe.getTranscriptionJob(params).promise();

        // Extract the job from the response
        const transcriptionJob = response['TranscriptionJob'];
        let transcriptFileUri = "none";
        if (transcriptionJob["Transcript"]) {
            if (transcriptionJob["Transcript"]["TranscriptFileUri"])
                transcriptFileUri = transcriptionJob["Transcript"]["TranscriptFileUri"]
        }

        return {
            Email: userEmail,
            TranscriptFileUri: transcriptFileUri,
            TranscriptionJobName: transcriptionJobName,
            TranscriptionJobStatus: response['TranscriptionJob']['TranscriptionJobStatus']
        };
    } catch (error) {
        console.error('Error:', error);
        // If there's an error, return an error response
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Error retrieving Transcribe job status' })
        };
    }
};