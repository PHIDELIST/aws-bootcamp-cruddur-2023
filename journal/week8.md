# Week 8 — Serverless Image Processing
## Create a New Directory
This top level directory will contain our cdk pipeline
``` 
cd /workspace/aws-bootcamp-cruddur-2023
mkdir thumbing-serverless-cdk
```
### Installing CDK globally
This will enable us to use our cdk command anywhere in the project workspace
``` 
npm install aws-cdk -g
```
**Add the installation command to Gitpod to enable its automatic installation during startup**
```
  - name: cdk
    before: |
      npm install aws-cdk -g
```
### Initialize a new project
In the directory created initialize new project by running the following commands
```
cdk init app --language typescript 
```
### Environment Variables
You can create your own environmental varibles in the Node REPL by appending a variable to the ``` process.env ``` object directly.
Insatll DotEnv by ``` npm i dotenv ``` .
#### Create a .env file for environmental variables in the ```SERVERLESS-IMAGE-PROCESSING-CDK``` dir.
```.env
THUMBING_BUCKET_NAME="assets.xysjs.xyz"
THUMBING_S3_FOLDER_INPUT="avatars/original"
THUMBING_S3_FOLDER_OUTPUT="avatars/processed"
THUMBING_WEBHOOK_URL="https://api.phidelis.xyz/webhooks/avatar"
THUMBING_TOPIC_NAME="cruddur-assets"
THUMBING_FUNCTION_PATH="/workspace/aws-bootcamp-cruddur-2023/aws/lambda/process-images"
```
### Bootstraping
Deploying stacks with the AWS CDK requires dedicated Amazon S3 buckets and other containers to be available to AWS CloudFormation during deployment. cdk bootstrap should be done once for the your account for each region.
``` 
cdk bootstrap "aws://[your account I'd]/[region]"
```
In AWS cloud formation we will find our CDK toolkit stack created with resources required.
![](/_docs/assets/cdkawstoolkitwk8.png)
### Adding IaC for the PipeLine writtten in typescript
cd back into the ```SERVERLESS-IMAGE-PROCESSING-CDK``` directory then install the following dependencies.
```
npm install aws-cdk-lib
npm install sharp
npm install dotenv
```
create a bucket manually in aws console with bucket name assets.phidel254.xyz import the bucket into the cdk stack.

cd into SERVERLESS-IMAGE-PROCESSING-CDK directory then into lib directory you will find a file ```thumbing-serverless-cdk-stack.ts``` Add the following codes
```.ts
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as s3n from 'aws-cdk-lib/aws-s3-notifications';
import * as subscriptions from 'aws-cdk-lib/aws-sns-subscriptions';
import * as sns from 'aws-cdk-lib/aws-sns';
import { config } from 'process';
import * as dotenv from 'dotenv';

// import * as sqs from 'aws-cdk-lib/aws-sqs';
//load env variables

dotenv.config();

export class ServerlessImageProcessingCdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // The code that defines your stack goes here
    const uploadsBucketName: string = process.env.UPLOADS_BUCKET_NAME as string;
    const assetsBucketName: string = process.env.ASSETS_BUCKET_NAME as string;
    const folderInput: string = process.env.THUMBING_S3_FOLDER_INPUT as string;
    const folderOutput: string = process.env.THUMBING_S3_FOLDER_OUTPUT as string;
    //const webhookUrl: string = process.env.THUMBING_WEBHOOK_URL as string;
    const topicName: string = process.env.THUMBING_TOPIC_NAME as string;
    const functionPath: string = process.env.THUMBING_FUNCTION_PATH as string;
    console.log('uploadsBucketName',uploadsBucketName)
    console.log('assetsBucketName',assetsBucketName)
    console.log('folderInput',folderInput)
    console.log('folderOutput',folderOutput)
    //console.log('webhookUrl',webhookUrl)
    console.log('topicName',topicName)
    console.log('functionPath',functionPath)
  
    const uploadsBucket = this.createBucket(uploadsBucketName);
    const assetsBucket = this.importBucket(assetsBucketName);

    const lambda = this.createLambda(
      functionPath, 
      uploadsBucketName, 
      assetsBucketName, 
      folderInput, 
      folderOutput
    );

//granting lambda read and write permission to s3
    uploadsBucket.grantRead(lambda);
    uploadsBucket.grantReadWrite(lambda);
    assetsBucket.grantRead(lambda);
    assetsBucket.grantReadWrite(lambda);

    // create topic and subscription
    const snsTopic = this.createSnsTopic(topicName)
    //this.createSnsSubscription(snsTopic,webhookUrl)

    // add our s3 event notifications
    this.createS3NotifyToLambda(folderInput,lambda,uploadsBucket)
    this.createS3NotifyToSns(folderOutput,snsTopic,assetsBucket)

    // create policies
    const s3UploadsReadWritePolicy = this.createPolicyBucketAccess(uploadsBucket.bucketArn)
    const s3AssetsReadWritePolicy = this.createPolicyBucketAccess(assetsBucket.bucketArn)
    //const snsPublishPolicy = this.createPolicySnSPublish(snsTopic.topicArn)

    // attach policies for permissions
    lambda.addToRolePolicy(s3UploadsReadWritePolicy);
    lambda.addToRolePolicy(s3AssetsReadWritePolicy);
    //lambda.addToRolePolicy(snsPublishPolicy);
    }
//creating bucket
  createBucket(bucketName: string): s3.IBucket {
    const bucket = new s3.Bucket(this, 'UploadsBucket', {
      bucketName: bucketName,
      removalPolicy: cdk.RemovalPolicy.DESTROY
    });
    return bucket;
  }

  importBucket(bucketName: string): s3.IBucket {
    const bucket = s3.Bucket.fromBucketName(this,"AssetsBucket",bucketName);
    return bucket;
  }

  //creating lambda 
  createLambda(functionPath: string, uploadsBucketName: string, assetsBucketName: string, folderInput: string, folderOutput: string): lambda.IFunction {
    const lambdaFunction = new lambda.Function(this, 'AvatarLambda',{
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset(functionPath),
      //final image specification
      environment:{
        DEST_BUCKET_NAME: assetsBucketName,
        FOLDER_INPUT: folderInput,
        FOLDER_OUTPUT: folderOutput,
        PROCESS_WIDTH: '512',
        PROCESS_HEIGHT: '512'

      }
  });
  return lambdaFunction;

  }
  //end creating lambda

  createS3NotifyToLambda(prefix: string, lambda: lambda.IFunction, bucket: s3.IBucket): void {
    const destination = new s3n.LambdaDestination(lambda);
    bucket.addEventNotification(
      s3.EventType.OBJECT_CREATED_PUT,
      destination,//
      //{prefix: prefix} // folder to contain the original images
    )
  }

  createPolicyBucketAccess(bucketArn: string){
    const s3ReadWritePolicy = new iam.PolicyStatement({
      actions: [
        's3:GetObject',
        's3:Putbject',
      ],
      resources: [
        `${bucketArn}/*`,
      ]
    });
    return s3ReadWritePolicy;
  }

  createSnsTopic(topicName: string): sns.ITopic{
    const logicalName = "AvatarTopic";
    const snsTopic = new sns.Topic(this, logicalName, {
      topicName: topicName
    });
    return snsTopic;
  }
//incase you will use webhook this is how to create its subscription 
  createSnsSubscription(snsTopic: sns.ITopic, webhookUrl: string): sns.Subscription {
    const snsSubscription = snsTopic.addSubscription(
      new subscriptions.UrlSubscription(webhookUrl)
    )
    return snsSubscription;
  }

  createS3NotifyToSns(prefix: string, snsTopic: sns.ITopic, bucket: s3.IBucket): void {
    const destination = new s3n.SnsDestination(snsTopic)
    bucket.addEventNotification(
      s3.EventType.OBJECT_CREATED_PUT, 
      destination,
      {prefix: prefix} // folder to contain the original images
    );
  }

 
}
  ```
Then set environmental variables 
   ```.env
   export THUMBING_BUCKET_NAME="bucket-name"
   gp env THUMBING_BUCKET_NAME="bucket-name"
   ```
### Create a Bash script for upload and delete object in S3
***Uploads***
```.sh
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
SERVERLESS_PATH=$(dirname $ABS_PATH)
DATA_FILE_PATH="$SERVERLESS_PATH/files/data.jpg"
aws s3 cp "$DATA_FILE_PATH" "s3://assets.$DOMAIN_NAME/avatars/original/data.jpg"
```
***delete***
```.sh
#! /usr/bin/bash

ABS_PATH=$(readlink -f "$0")
SERVERLESS_PATH=$(dirname $ABS_PATH)
DATA_FILE_PATH="$SERVERLESS_PATH/files/data.jpg"
aws s3 rm "s3://assets.$DOMAIN_NAME/avatars/original/data.jpg"
aws s3 rm "s3://assets.$DOMAIN_NAME/avatars/processed/data.jpg"
```
export the env varriable of domain name
```.sh
export DOMAIN_NAME="phidelixyz.com"
gp env DOMAIN_NAME="phidelisxyz.com"
```
  
### Creating the Lambda Fucntions
Then install the following dependencies into the lambdas directory.
```
npm install sharp

npm install @aws-sdk/client-s3 

npm install dotenv
```
cd into the the ```aws/lambdas/imageprocessing```dir the add the following lambda functions
+ index.js
```.js
// Import required modules
const process = require('process');
const {getClient, getOriginalImage, processImage, uploadProcessedImage} = require('./s3-image-processing.js')
const path = require('path');

// Retrieve environment variables
const bucketName = process.env.DEST_BUCKET_NAME
const folderInput = process.env.FOLDER_INPUT
const folderOutput = process.env.FOLDER_OUTPUT
const width = parseInt(process.env.PROCESS_WIDTH)
const height = parseInt(process.env.PROCESS_HEIGHT)

// Create an S3 client using the AWS SDK for JavaScript
client = getClient();

// Export an async function as the handler for AWS Lambda
exports.handler = async (event) => {
    // Extract the name of the source bucket and key from the Lambda event
  const srcBucket = event.Records[0].s3.bucket.name;
  const srcKey = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
  console.log('srcBucket',srcBucket)
  console.log('srcKey',srcKey)
// Extract the name of the source bucket and key from the Lambda event
  const dstBucket = bucketName;

  filename = path.parse(srcKey).name
  const dstKey = `${folderOutput}/${filename}.jpeg`
  console.log('dstBucket',dstBucket)
  console.log('dstKey',dstKey)

 // Retrieve the original image from the source bucket
  const originalImage = await getOriginalImage(client,srcBucket,srcKey)
  // Process the original image to create a new image with the specified width and height
  const processedImage = await processImage(originalImage,width,height)
  // Upload the processed image to the destination bucket with the specified key
  await uploadProcessedImage(client,dstBucket,dstKey,processedImage)
};
```
+ s3-image-processing.js
```.js
// Import the required modules
const sharp = require('sharp');
const { S3Client, PutObjectCommand, GetObjectCommand } = require("@aws-sdk/client-s3");

// Define a function to create an S3 client instance
function getClient(){
  const client = new S3Client();
  return client;
}

// Define a function to retrieve the original image from S3
async function getOriginalImage(client,srcBucket,srcKey){
  // Define the parameters for retrieving the object from S3
  const params = {
    Bucket: srcBucket,
    Key: srcKey
  };
  // Define the command for retrieving the object from S3
  const command = new GetObjectCommand(params);
  // Send the command to S3 and retrieve the response
  const response = await client.send(command);

  // Retrieve the image data from the response
  const chunks = [];
  for await (const chunk of response.Body) {
    chunks.push(chunk);
  }
  const buffer = Buffer.concat(chunks);

  // Return the image data as a buffer
  return buffer;
}

// Define a function to process the image with Sharp
async function processImage(image,width,height){
  // Use Sharp to resize and convert the image to PNG format
  const processedImage = await sharp(image)
    .resize(width, height)
    .png()
    .toBuffer();
  
  // Return the processed image data as a buffer
  return processedImage;
}

// Define a function to upload the processed image to S3
async function uploadProcessedImage(client,dstBucket,dstKey,image){
  // Define the parameters for uploading the object to S3
  const params = {
    Bucket: dstBucket,
    Key: dstKey,
    Body: image,
    ContentType: 'image/jpeg'
  };
  // Define the command for uploading the object to S3
  const command = new PutObjectCommand(params);
  // Send the command to S3 and retrieve the response
  const response = await client.send(command);

  // Log the response and return it
  console.log('response',response);
  return response;
}

// Export the functions for use in other modules
module.exports = {
  getClient: getClient,
  getOriginalImage: getOriginalImage,
  processImage: processImage,
  uploadProcessedImage: uploadProcessedImage
}
```
+ test.js
```.js
const {getClient, getOriginalImage, processImage, uploadProcessedImage} = require('./s3-image-processing.js')

async function main(){
  client = getClient()
  const srcBucket = 'thumbing.phidel'
  const srcKey = 'avatar/original/data.jpg'
  const dstBucket = 'thumbing.phidel'
  const dstKey = 'avatar/processed/data.png'
  const width = 256
  const height = 256

  const originalImage = await getOriginalImage(client,srcBucket,srcKey)
  console.log(originalImage)
  const processedImage = await processImage(originalImage,width,height)
  await uploadProcessedImage(client,dstBucket,dstKey,processedImage)
}

main()
```
Go to the root directory of ``` SERVERLESS-IMAGE-PROCESSING-CDK``` dir then;
+ npm run build :
it will only build the typescript
it is used to catch errors prematurely and enables the CDK to abandon resources that can't build due to some reasons and build the rest of the resources.
```.sh
npm run build
```
+ CDK synth :
This will synthesize the AWS CloudFormation stack(s) that represent your infrastructure as code.
```.sh
cdk synth
```
+ CDK deploy:
This will deploy your stack to the AWS cloud.
```.sh
cdk deploy
```
+ CDK ls:
This will list your available stacks in AWS CloudFormation.
```.sh
cdk ls
```
***How to solve sharp error***
```.sh
npm install
rm -rf node_modules/sharp
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install --arch=x64 --platform=linux --libc=glibc sharp
```
## Building up the cloudfront for Serving Avatars.
Amazon CloudFront is a web service that speeds up distribution of your static and dynamic web content, such as .html, .css, .js, and image files, to your users. CloudFront delivers your content through a worldwide network of data centers called edge locations. When a user requests content that you're serving with CloudFront, the request is routed to the edge location that provides the lowest latency (time delay), so that content is delivered with the best possible performance.
If the content is already in the edge location with the lowest latency, CloudFront delivers it immediately.
If the content is not in that edge location, CloudFront retrieves it from an origin that you've defined—such as an Amazon S3 bucket, a MediaPackage channel, or an HTTP server (for example, a web server) that you have identified as the source for the definitive version of your content.
***Distribution***
![]()





















