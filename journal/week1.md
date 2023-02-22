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
+ I used the following code to build the container
 ```docker build -t backend-flask ./backend-flask```
***Running the Container in the backgroung***
+ I used the following code to run the container 
 ```docker container run --rm -p 4567:4567 -d backend-flask```
 #### checking container images and running container Ids 
 + ```docker ps
 ``` to check running containers
 + ```docker images
 ``` to check container images
 
