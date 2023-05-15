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
#### Create a .env file for environmental variables

### Bootstraping
Deploying stacks with the AWS CDK requires dedicated Amazon S3 buckets and other containers to be available to AWS CloudFormation during deployment. cdk bootstrap should be done once for the your account for each region.
``` 
cdk bootstrap "aws://[your account I'd]/[region]"
```


