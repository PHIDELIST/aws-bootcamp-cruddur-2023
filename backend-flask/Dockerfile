FROM 576997243977.dkr.ecr.us-east-1.amazonaws.com/cruddur-python:3.10-slim-buster

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
#ENV FLASK_DEBUG=1

#HEALTHCHECK CMD curl --fail http://localhost:4567 || exit 1   

EXPOSE ${PORT}

# CMD(command)
# python3 -m flask run --host=0.0.0.0 --port=4567
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567", "--debug"]