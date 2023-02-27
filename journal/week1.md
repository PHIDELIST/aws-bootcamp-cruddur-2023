# Week 1 — App Containerization
I am using gitpod as my cloud development envirionment and it comes with docker extension preinstalled.
## Containerizing the Backend
The backend of cruddur application has been coded in python programming language.
### Backend Dockerfile
```Dockerfile
 FROM python:3.10-slim-buster

# inside the container
# makes a new folder inside the container
WORKDIR /backend-flask

#Outside container -> Insider Container
# this contains the libraries want to install to run the app
COPY requirements.txt requirements.txt

# inside container
# install the python libraries used for the app
RUN pip3 install -r requirements.txt

# outside container -> inside container
# . means everything in the current directory
# first period . /backend-flask (outside container)
# second period . /backend-flask(inside container)
COPY . .

# set environment viriables 
# Inside container and will remain set when the container is running
ENV FLASK_ENV=development

EXPOSE ${PORT}

# CMD(command)
# python3 -m flask run --host=0.0.0.0 --port=4567
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```
***Building the container***
+ I used the following command to build the container
 ```docker build -t backend-flask ./backend-flask```
#### Running the Container in the backgroung
+ I used the following command to run the container 
 ```docker container run --rm -p 4567:4567 -d backend-flask```
 #### checking container images and running container Ids 
 + ```docker ps```to check running containers
 + ```docker images``` to check container images
 #### Checking container logs 
 Return the container id into an ENV vat
 ```.yml
 CONTAINER_ID=$(docker run --rm -p 4567:4567 -d backend-flask)
 ```
 I used the following command to check log of backend container
 ```.yml
 docker logs CONTAINER_ID -f
 ```
 + ***To gain access to a container***
 ```.yml
 docker exec CONTAINER_ID -it /bin/bash
 ```
 ## Containerizing Frontend
 ### Run npm install to copy contents of node_modules
 ```cd frontend-react-js
 npm i 
 ```
 ### Dockerfile 
 create the following dockerfile in the same directory
 ```Dockerfile
 FROM node:16.18

ENV PORT=3000

COPY . /frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
EXPOSE ${PORT}
CMD ["npm", "start"]
```
***BUILD CONTAINER***
```docker build -t frontend-react-js ./frontend-react-js```

***RUN CONTAINER***
```docker run -p 3000:3000 -d frontend-react-js```
## Creating Docker-Compose File
Here i created the docker-compose file in the root directory.
Compose file is used for defining and running multi-container applications.
In this case there is four applications that  I'm going to define using the compose file:
+ Frontend application
+ Backend application
+ Postgres db
+ Dynamodb

***First postgres client nedd to be installed in Gitpod***
The following code of commands is added to the gitpod
```
  - name: postgres
    init: |
      curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
      echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
      sudo apt update
      sudo apt install -y postgresql-client-13 libpq-dev
 ```
### Docker-compose file
```.yml
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js
  db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data
  dynamodb-local:
    # https://stackoverflow.com/questions/67533058/persist-local-dynamodb-data-in-volumes-lack-permission-unable-to-open-databa
    # We needed to add user:root to get this working.
    user: root
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
    image: "amazon/dynamodb-local:latest"
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - "./docker/dynamodb:/home/dynamodblocal/data"
    working_dir: /home/dynamodblocal

# the name flag is a hack to change the default prepend folder
# name when outputting the image names
networks: 
  internal-network:
    driver: bridge
    name: cruddur
volumes:
  db:
    driver: local
````
## Confirming connection to the postgres database
![postgres database connection screenshot](/_docs/assets/connection_psql.png)
![psql templetes screenshot](/_docs/assets/psql-tables.png)
## Updating openAPI to add notification endpoint
I added the following code to the openapi
```.yml
 /api/activities/notifications:
    get:
      description: 'return a feed of activities for all those i follow'
      tags:
        - activies
      parameters: []
      responses:
        '200':
          description: return array of activities
          content:
            application/json:
              schema:
               type: array
               items: 
                $ref: '#/components/schemas/Activity'
```
+ notification API response sample screenshot
![notifation api screenshot](/_docs/assets/notificatio_api_response_sample.png)
## Flask backend endpoint for notification
In the file ```app.py``` I added the following code for the notification endpoint
```.py
# import notification activities from services
from services.notifications_activities import *
# get operation for the endpoint
@app.route("/api/activities/notifications", methods=['GET'])
def data_notifications():
  data = NotificationsActivities.run()
  return data, 200
```

## React page for notifications 
I managed to follow Andrew browns' instructions on adding notification page.
I successfully added the notification page and ensured it is working.
 ![Notification page screenshot](/_docs/assets/notification_page.png)

# Homework challenges
## Push and tag a image to DockerHub
I managed to push an image to the dockerhub
First you have to tag the image with the repository name the you push it.
![docker image push to dockerhub](/_docs/assets/docker-hub-backend.png)

## Learn how to install Docker on your localmachine and get the same containers running outside of Gitpod / Codespaces
image to run crudder containers locally on decker desktop
![dockerdesktop](/_docs/assets/cruddur-docker-local.png)
## Launch an EC2 instance that has docker installed, and pull a container to demonstrate you can run your own docker processes. 
I used the following script as user data to install docker on the ec2 instance during setup
```.sh
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo systemctl enable docker
sudo systemctl enable docker
```

![ec2 instance with docker installed](/_docs/assets/docker-container-pulled.png)
