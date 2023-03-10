# Week 3 — Decentralized Authentication
## Install AWS Amplify 
Run the following command on the terminal to install Amplify
```npm i aws-amplify --save```

## Create Cognito User Pool
Using AWS console create a user pool with the following configurations
+ Authenticated provider type choose **Cognito User Pool**
+ Cognito user pool sign-in options choose **Email**
+ Pasword Policy mode choose **Cognito defaults**
+ Multi-factor authentication choose **No-MFA**
+ User account recovery choose **Enable self-service account recovery**
+ Delivery method for user account recovery messages choose **Email only**
+ Self-service sign-up choose **Enable self-registration**
+ Attribute verification and user account confirmation choose **Allow Cognito to automatically send messages to verify and confirm**
+ Attributes to verify choose **Send email message, verify email address**
+ Verify attribute changes choose **Keep original attribute value active when an update is pending**
+ Active attribute values when an update is pending choose **Email address**
+ Additional required attributes choose **preferred_username, name**
+   Configure message delivery choose **Send email with cognito**
+   FROM email address leave it as cognito default
+   Under Integrate your app enter user pool name as **cruddur-user-pool
+   Hosted authentication pages uncheck **use the cognito hosted UI**
+   Initial app client choose **public app client**
+   App client name enter **Cruddur**
+   Client secret choose **Don't generate a client secret**
+   Review your settings then click **Create user pool**
![cognito user pool id](/_docs/assets/cruddur-user-pool.png)
## Configuring Amplify
connect cognito user pool to the ```App.js```  by adding thse code
```.js
import { Amplify } from 'aws-amplify';

Amplify.configure({
  "AWS_PROJECT_REGION": process.env.REACT_APP_AWS_PROJECT_REGION,
  "aws_cognito_region": process.env.REACT_APP_AWS_COGNITO_REGION,
  "aws_user_pools_id": process.env.REACT_APP_AWS_USER_POOLS_ID,
  "aws_user_pools_web_client_id": process.env.REACT_APP_CLIENT_ID,
  "oauth": {},
  Auth: {
    // We are not using an Identity Pool
    // identityPoolId: process.env.REACT_APP_IDENTITY_POOL_ID, // REQUIRED - Amazon Cognito Identity Pool ID
    region: process.env.REACT_APP_AWS_PROJECT_REGION,           // REQUIRED - Amazon Cognito Region
    userPoolId: process.env.REACT_APP_AWS_USER_POOLS_ID,         // OPTIONAL - Amazon Cognito User Pool ID
    userPoolWebClientId: process.env.REACT_APP_CLIENT_ID,  // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
  }
});
```
## Conditionally show components based on lagged in or logged out
add the following code into ```HomeFeedPage.js```
```.js
import { Auth } from 'aws-amplify';
const checkAuth = async () => {
    Auth.currentAuthenticatedUser({
      // Optional, By default is false. 
      // If set to true, this call will send a 
      // request to Cognito to get the latest user data
      bypassCache: false 
    })
    .then((user) => {
      console.log('user',user);
      return Auth.currentAuthenticatedUser()
    }).then((cognito_user) => {
        setUser({
          display_name: cognito_user.attributes.name,
          handle: cognito_user.attributes.preferred_username
        })
    })
    .catch((err) => console.log(err));
  };
```
**CONTENTS DISPLAYED BEFORE USER LOG IN**

@Lore Crudds are not visible before user log in
![before user login](/_docs/assets/Activities-before-login.png)
@Lore Crudds are shown when a user successfuly loged in
![After user log in](/_docs/assets/activities-after-loggin.png)

