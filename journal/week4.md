# Week 4 — Postgres and RDS

#### connect to local postgres database client via psql cli
```psql -Upostgres --host localhost```

The host flag must be included to specify that psql client is running in the local host

***Common PSQL commands:***
```
\x on -- expanded display when looking at data
\q -- Quit PSQL
\l -- List all databases
\c database_name -- Connect to a specific database
\dt -- List all tables in the current database
\d table_name -- Describe a specific table
\du -- List all users and their roles
\dn -- List all schemas in the current database
CREATE DATABASE database_name; -- Create a new database
DROP DATABASE database_name; -- Delete a database
CREATE TABLE table_name (column1 datatype1, column2 datatype2, ...); -- Create a new table
DROP TABLE table_name; -- Delete a table
SELECT column1, column2, ... FROM table_name WHERE condition; -- Select data from a table
INSERT INTO table_name (column1, column2, ...) VALUES (value1, value2, ...); -- Insert data into a table
UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition; -- Update data in a table
DELETE FROM table_name WHERE condition; -- Delete data from a table
```

## Provisioning Postgres RDS instance via aws-cli
RDS instance take around 10-15 minutes to spin up.
```
aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username root \
  --master-user-password ******* \
  --allocated-storage 20 \
  --availability-zone us-east-1a \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
  ```
  
## Installing Postgres Client
First set env var for the backend-flask application
```
    backend-flask:
    environment:
      CONNECTION_URL: "${CONNECTION_URL}"
```

Add the following to the  ```requirements.txt```

```
psycopg[binary]
psycopg[pool]
```

Then run the following command:

```pip install -r requirements.txt```

  ***CREATING ENVIRONMENTAL VARIABLES***
  
  ```
  postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]    #syntax example to connect postgres
export CONNECTION_URL="postgresql://your_db_username:your_db_password@localhost:5432/cruddur"  # export variable localy
gp env CONNECTION_URL="postgresql://your_db_username:your_db_password@localhost:5432/cruddur"  # export variable into gitpod variables storage

export PROD_CONNECTION_URL="postgresql://your_aws_postgres_username:your_aws_postgres_password@your_db_instance_endpoint:5432/cruddur"   # export variable localy
gp env PROD_CONNECTION_URL="postgresql://your_aws_postgres_username:your_aws_postgres_password@your_db_instance_endpoint:5432/cruddur"   # export variable into gitpod variables storage
```

## Creating Tables in database
 In the backend flask make a folder called db   ```backend-flask/db```
 
 Then make a file called schema.sql   ```backend-flask/db/schema.sql```
 ```.sql

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;

CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text NOT NULL,
  handle text NOT NULL,
  email text NOT NULL,
  cognito_user_id text NOT NULL,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID NOT NULL,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

```

***Seed data:***
Make file ```backend-flask/db/seed.sql```
```.sql
-- this file was manually created
INSERT INTO public.users (display_name, handle, email, cognito_user_id)
VALUES
  ('phidel', 'phidel' , 'phidelisoluoch@gmail.com' , 'e0b69ea1-57e2-42ad-8025-dd372666785d');
  
INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'phidel' LIMIT 1),
    'This is my first crudd!',
    current_timestamp + interval '10 day'
  )
```

## Bash Scripts
make folder in  ```backend-flask/bin/:```

***db-create script***

```backend-flask/bin/db-create```

```
#! /usr/bin/bash

 
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="DB-CREATE"
printf "${CYAN}== ${LABEL} ==${NO_COLOR}\n"

 
NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "create database cruddur;"
```

Then make it executable:

```chmod u+x ./bin/db-create```

***db-drop script***

```backend-flask/bin/db-drop```

```
#! /usr/bin/bash

 
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="DB-DROP"
printf "${CYAN}== ${LABEL} ==${NO_COLOR}\n"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "DROP DATABASE cruddur;"
```

make it executable  ```chmod u+x ./bin/db-drop```

***db-connect script***

```backend-flask/bin/db-connect```

```
#! /usr/bin/bash


GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="DB-CONNECT"
printf "${CYAN}== ${LABEL} ==${NO_COLOR}\n"



if [ "$1" = "prod" ]; then
    printf "${GREEN}It's PRODUCTION!${NO_COLOR}\n"
    CON_URL=$PROD_CONNECTION_URL
else
    printf "${RED}NOT PRODUCTION!${NO_COLOR}\n"
    CON_URL=$CONNECTION_URL
fi


psql $CON_URL
```

make it executable  ```chmod u+x ./bin/db-connect```

Run the script using  ```./bin/db-connect prod```  to connect to RDS postgres databse 
Then run a simple query  ```SELECT * from users;```

![table user](/_docs/assets/PSQL-TB.png)

***db-schema-load***

```backend-flask/bin/db-schema-load```

```
#!/usr/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="DB-SCHEMA-LOADED"
printf "${CYAN}== ${LABEL} ==${NO_COLOR}\n"

schema_path="$(realpath .)/db/schema.sql"
echo $schema_path

if [ "$1" = "prod" ]; then
    printf "${GREEN}It's PRODUCTION!${NO_COLOR}\n"
    CON_URL=$PROD_CONNECTION_URL
else
    printf "${RED}NOT PRODUCTION!${NO_COLOR}\n"
    CON_URL=$CONNECTION_URL
fi

psql $CON_URL cruddur < $schema_path
```

make it executable  ```chmod u+x ./bin/db-schema-load```

***db-seed script***

```backend-flask/bin/db-seed```

```
#!/usr/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="DB-SEED"
printf "${CYAN}== ${LABEL} ==${NO_COLOR}\n"

seed_path="$(realpath .)/db/seed.sql"
echo $seed_path

if [ "$1" = "prod" ]; then
    printf "${GREEN}It's PRODUCTION!${NO_COLOR}\n"
    CON_URL=$PROD_CONNECTION_URL
else
    printf "${RED}NOT PRODUCTION!${NO_COLOR}\n"
    CON_URL=$CONNECTION_URL
fi

psql $CON_URL cruddur < $seed_path
```

make it executable  ```chmod u+x ./bin/db-seed```

***db-setup***

```backend-flask/bin/db-setup```

```
#! /usr/bin/bash

 
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="DB-SETUP"
printf "${CYAN}== ${LABEL} ==${NO_COLOR}\n"

bin_path="$(realpath .)/bin"
 

 
source "$bin_path/db-drop"
source "$bin_path/db-create"
source "$bin_path/db-schema-load"
source "$bin_path/db-seed"
```

make it executable  ```chmod u+x ./bin/db-setup```

***db-session script***

```backend-flask/bin/db-session```

```
#! /usr/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="DB-SESSIONS"
printf "${CYAN}== ${LABEL} ==${NO_COLOR}\n"


if [ "$1" = "prod" ]; then
    printf "${GREEN}It's PRODUCTION!${NO_COLOR}\n"
    CON_URL=$PROD_CONNECTION_URL
else
    printf "${RED}NOT PRODUCTION!${NO_COLOR}\n"
    CON_URL=$CONNECTION_URL
fi
 
NO_DB_URL=$(sed 's/\/cruddur//g' <<<"$CON_URL")
psql $NO_DB_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"
```

make it executable  ```chmod u+x ./bin/db-session```

***rds-upgrade-sg-rule***

```backend-flask/bin/rds-update-sg-rule```

```
#!/usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="RDS-UPDATE-SG-RULE"
printf "${CYAN}== ${LABEL} ==${NO_COLOR}\n"

counter=0
while ! aws ec2 describe-instances &> /dev/null
do
    printf "AWS CLI is not installed yet, waiting for ${counter} seconds...\n"
    sleep 1
    ((counter++))
done

aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```

Make it executable  ```chmod u+x ./bin/rds-upgrade-sg-rule```

## DB Oject and Connection Pool

In  ```backend-flask/lib``` add ```db.py``` then:

```
from psycopg_pool import ConnectionPool
import os

 
def query_wrap_object(template):
  sql = f"""
  (SELECT COALESCE(row_to_json(object_row),'{{}}'::json) FROM (
  {template}
  ) object_row);
  """
  return sql

def query_wrap_array(template):
  sql = f"""
  (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
  {template}
  ) array_row);
  """
  return sql


connection_url = os.getenv("CONNECTION_URL")
pool = ConnectionPool(connection_url)
```

In the home-activities replace mock endpoint with real api call:

```
from lib.db import pool, query_wrap_array

      sql = query_wrap_array("""
      SELECT
        activities.uuid,
        users.display_name,
        users.handle,
        activities.message,
        activities.replies_count,
        activities.reposts_count,
        activities.likes_count,
        activities.reply_to_activity_uuid,
        activities.expires_at,
        activities.created_at
      FROM public.activities
      LEFT JOIN public.users ON users.uuid = activities.user_uuid
      ORDER BY activities.created_at DESC
      """)
      print(sql)
      with pool.connection() as conn:
        with conn.cursor() as cur:
          cur.execute(sql)
          # this will return a tuple
          # the first field being the data
          json = cur.fetchone()
      return json[0]
```

## Connect RDS to Gitpod
To connect RDS to gitpod add Gitpod IP addess to the allowed inbound traffic on port 5432

```
export GITPOD_IP=$(curl ifconfig.me)

gp env GITPOD_IP=$(curl ifconfig.me)
```

Get the security group rule id and security group id to enable easy future modification

```
export DB_SG_ID="sg-0b725ebab7e25635e"
gp env DB_SG_ID="sg-0b725ebab7e25635e"
export DB_SG_RULE_ID="sgr-070061bba156cfa88"
gp env DB_SG_RULE_ID="sgr-070061bba156cfa88"
```

To update the security groups run the following commands in the terminal;

```
aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```
***Update Gitpod IP on new env vars***
```
    command: |
      export GITPOD_IP=$(curl ifconfig.me)
      source "$THEIA_WORKSPACE_ROOT/backend-flask/db-update-sg-rule"
```
## Lambda Functions for Developments
In the AWS console create a lambda function.
Define environmental varriable with KEY=```CONNECTION_URL``` and VALUE=```PROD_CONNECTION_ULR ```value
In the repository Make folder ```aws/lambdas``` then a file ```cruddur-post-confirmation.py``
```.py

import json
import psycopg2
import os

def lambda_handler(event, context):
    user = event['request']['userAttributes']
    user_display_name=user['name']
    user_email=user['email']
    user_handle=user['preferred_username']
    user_cognito_id=user['sub']
     
    try:
        sql = f"""
        INSERT INTO users (display_name, email,handle, cognito_user_id) 
        VALUES('{user_display_name}','{user_email}','{user_handle}','{user_cognito_id}')
        """

        conn = psycopg2.connect(os.getenv('CONNECTION_URL'))
        cur = conn.cursor()
        cur.execute(sql)
        conn.commit() 

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
    finally:
        if conn is not None:
            cur.close()
            conn.close()
            print('Database connection closed.')

    return event
```

Delpoy the script above also to lambda code in the console.

***Create custom lambda layer***
Follow the following steps

```mkdir aws-psycopg2

cd aws-psycopg2

vi get_layer_packages.sh

export PKG_DIR="python"

rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR}

docker run --rm -v $(pwd):/foo -w /foo lambci/lambda:build-python3.6 \
    pip install -r requirements.txt --no-deps -t ${PKG_DIR}
vi requirements.txt

aws-psycopg2
then do : chmod +x get_layer_packages.sh

./get_layer_packages.sh

zip -r aws-psycopg2.zip .
```

The upload the zipped file to AWS lambda layer.

***Add configure lambda with VPC***
+ choose the default VPC
+ choose the two subnets from the default VPC
+ choose the default security group

***Add permission to lambda function to be able to modift networkinterfaces***
+ Go to IAM 
+ Create new AWS policy
+ The attach the new AWS policy to the AWS role
```

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
```
**Posting on Cruddur**
![cruudur posting screenshot](/_docs/assets/posting%20is%20working.png)
      
     

