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
My AWS account usually have billing enabled with preference of receive billing alerts.
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
+ The following is my screenshots of the budget and billing alarm 
![MY bootcamp budget](/_docs/assets/budget.png)
![My billing-alarm-screenshot](/_docs/assets/Billing-alarm.png)
## Recreation of architectural Napkin diagram using lucid chart
I recreated a napkin diagram for Cruddur application
[Here is the lucid link to the napkin diagram](https://lucid.app/lucidchart/ac4e3a51-6dfd-4ffa-a6e4-791d4559a406/edit?viewport_loc=-246%2C-74%2C1707%2C701%2C0_0&invitationId=inv_eddda734-d330-4be9-b21b-38221b9423a5)
![Cruddur app napkin diagram](/_docs/assets/CRUDDUR_APP_napkin_diagram.png)
## Recreation of architectural Logical diagram using lucid chart
I used lucid chart to recreate Cruddur app logical diagram
[Here is the lucid link to the logical diagram](https://lucid.app/lucidchart/b896f0bc-bdb4-4ce6-84eb-9b58dcae3705/edit?viewport_loc=261%2C127%2C1735%2C713%2C0_0&invitationId=inv_4ac188af-3926-49d5-bf2d-09a48c0fa93b)
![Cruddur logical diagram](/_docs/assets/Phidelist_Omuya_cruddur_Logical_diagram.png)
### HOMEWORK CHALLENGES
## CI/CD logical diagram
+ I used lucid charts to create this CI/CD code pipeline [Here is the link to lucid charts for CI/CD logical diagram](https://lucid.app/lucidchart/ca27e965-b0eb-4568-97a2-4a0d8a8c43b9/edit?viewport_loc=-274%2C-368%2C1707%2C701%2C0_0&invitationId=inv_fc03974c-4b9b-465d-839d-635fd63d367f)
![CICD Logical diagram](/_docs/assets/Cruddur_CI_CD_diagram.png)
+ **AWS RESOURCE HEALTH MONITORING**
I linked my AWS health dashboard with my SNS topic through AWS EventBridge to monitor and notify me when there is an health issue(change in state on my instances).
![AWS heath](/_docs/assets/AWS-health-screenshot.png)
### WELL ARCHITECTED FRAMEWORK SUMMARY SCREENSHOTS
![well architected overview](/_docs/assets/well-architected-overview.png)
![well architected properties section](/_docs/assets/cruddur-W-A-screenshot.png)
