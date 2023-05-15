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
