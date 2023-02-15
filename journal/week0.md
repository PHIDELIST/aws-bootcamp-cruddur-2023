# Week 0 — Billing and Architecture
## Installation of AWS CLI
+ I automated installation of AWS CLI anytime my Gitpod environment launches.
+ I accomplished this by use of bash commands available at [AWS CLI Installation instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
Below is the code that i used in my  ``.gitpod.yml``
```.yaml
tasks:
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    init: |
      cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT
vscode:
  extensions:
    - 42Crunch.vscode-openapi
```
## Creation of billing alarm
My AWS account usually have billing enable with preference of receive billing alerts.
### creation of SNS topic to be used with the alarm
I created the SNS topic through the AWS CLI by running the following command.
``` aws sns create tpoic -- name billing-alarm ```
+ The following is the screenshot of the my SNS topic:
![SNS topic](/_docs/assets/SNS-topic.png)
### creation of alarm 
I created  a bugdet alarm this is to help me avoid over pending during the bootcamp.
i created a budget and notifications json files in my code repo.
+ Then I used the following AWS cli command to create the cost and usage budget
```aws budgets create-budget \
    --account-id 576997243977 \
    --budget file://aws/json/budget.json \
    --notifications-with-subscribers file://aws/json/notifications-with-subscribers.json
```
+ The following is my screenshots of the budget
![MY bootcamp budget](/_docs/assets/budget.png)
+
