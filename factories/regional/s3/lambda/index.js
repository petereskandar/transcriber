const AWS = require('aws-sdk');
// Create the Step Functions service object
const stepfunctions = new AWS.StepFunctions();

exports.handler = async (event, context) => {
  try {
    const s3Event = event.Records[0].s3; // Assuming only one record in the event

    // Get the S3 bucket and object information
    const bucket = s3Event.bucket.name;
    const key = decodeURIComponent(s3Event.object.key.replace(/\+/g, ' '));

    // Define your Step Function ARN
    const stepFunctionArn = process.env.STATEMACHINEARN;

    // Start the Step Function execution
    const params = {
      stateMachineArn: stepFunctionArn,
      name: `Execution-${Date.now()}`, // Change the execution name as needed
      input: JSON.stringify({ "Bucket": bucket, "Key": key }), // Pass relevant data to your Step Function
    };

    await stepfunctions.startExecution(params).promise();

    console.log(`Started Step Function execution for file: ${key}`);

    return {
      statusCode: 200,
      body: JSON.stringify('Step Function execution started successfully.'),
    };
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};
