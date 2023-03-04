# Week 2 — Distributed Tracing
Distributed tracing is a method to connect a single request across multiple services, in cruddur it is enhanced through instrumentation of the application to help monitor its performance and identify error at earlier stages.
## HoneyComb
it is a software debugging tool that can help you solve problems faster within your distributed services.
Grab the API key from honeycomb account
``` export HONEYCOMB_API_KEY="TP0*CGWr4pvOLwiyO****"
    gp env HONEYCOMB_API_KEY="TP0*CGWr4pvOLwiyOyhV***"
 ```
+ New dataset is creatred in honeycomb through the following installation procedures.
Add the following dependancies to ```requirements.txt```
```.txt
opentelemetry-api 
opentelemetry-sdk 
opentelemetry-exporter-otlp-proto-http 
opentelemetry-instrumentation-flask 
opentelemetry-instrumentation-requests
```
To install the above dependancies do;
```pip install -r requirements.tx```
Add the following to the ```app.py```
```.py
#honeycomb---------
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor


# honeycomb******Initialize tracing and an exporter that can send data to Honeycomb
provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)
```
Under ```app = Flask(__name__)``` add the following code.
```.py
# honeycomb******Initialize automatic instrumentation with Flask
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()
```
Put the following Env Vars to ```backend-flask``` in docker compose
```
 OTEL_SERVICE_NAME: "backend-flask"
 OTEL_EXPORTER_OTLP_ENDPOINT: "https://api.honeycomb.io"
 OTEL_EXPORTER_OTLP_HEADERS: "x-honeycomb-team=${HONEYCOMB_API_KEY}" 
 ````
 To trace the activities.home add the following
```.py
from opentelemetry import trace
```
 ***Dashboard screenshot***
![Honeycomb dashboard screenshot](/_docs/assets/honeycomb-dashboard.png)

## Rollbar
In the Rollbar website create a project called ```Cruddur```
Add dependancies to ```requirements.txt``` then install them.
```.txt
blinker
rollbar
```
grab the access token from the project created in rollbar
```
export ROLLBAR_ACCESS_TOKEN="a729764*0e0a4025949c280a1f****"
gp env ROLLBAR_ACCESS_TOKEN="a729764**e0a4025949c280a1*****"
```
Add the following to backend-flask ```docker-compose.yml```
```.yml
ROLLBAR_ACCCESS_TOKEN: "${ROLLBAR_ACCCESS_TOKEN}"
```
Add the following to ```app.py```
```.py
#rollbar------------
import os
import rollbar
import rollbar.contrib.flask
from flask import got_request_exception
```
Below ```app = Flask(__name__)```
```.py
#rollbar-------------------------
rollbar_access_token = os.getenv('ROLLBAR_ACCESS_TOKEN')
@app.before_first_request
def init_rollbar():
    """init rollbar module"""
    rollbar.init(
        # access token
        'a729764c0e0a4025949c280a1f323173',
        # environment name
        'production',
        # server root directory, makes tracebacks prettier
        root=os.path.dirname(os.path.realpath(__file__)),
        # flask already sets up logging
        allow_logging_basic_config=False)

    # send exceptions from `app` to rollbar, using flask's signal system.
    got_request_exception.connect(rollbar.contrib.flask.report_exception, app
 # create an itentional error function to test our instrumentation 
 #rollbar endpoint--------
@app.route('/rollbar/test')
def rollbar_test():
    rollbar.report_message('Hello World!', 'warning')
    return "Hello World!"
 ```
![Rollbar dashboard screenshot](/_docs/assets/ROLLBAR-DASHBOARD.png)
    
## CloudWatch Logs
Add ```watchtower``` to the ```requirements.txt``` then run ```pip install -r requirements.txt```

set the env var in backend-flask for ```docker-compose.yml```
```.yml
      AWS_DEFAULT_REGION: "${AWS_DEFAULT_REGION}"
      AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
```
Add the following to ```app.py```
```.py
# cloudwatch logs
import watchtower
import logging
from time import strftime
Configuring Logger to Use CloudWatch
LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.DEBUG)
console_handler = logging.StreamHandler()
cw_handler = watchtower.CloudWatchLogHandler(log_group='cruddur')
LOGGER.addHandler(console_handler)
LOGGER.addHandler(cw_handler)
LOGGER.info("test log")
```
under ```app = Flask(__name__)``` add
```.py
# cloudwatch logs
@app.after_request
def after_request(response):
    timestamp = strftime('[%Y-%b-%d %H:%M]')
    LOGGER.error('%s %s %s %s %s %s', timestamp, request.remote_addr, request.method, request.scheme, request.full_path, response.status)
    return response
```
To trace the activities.home add the following
```.py
import logging
```
![cloudwatch dashboard screenshot](/_docs/assets/cloudwatch-logs.png)

## Instrumenting X-Ray for flask
Put the env var 
```export AWS_REGION="us-east-1"
   gp env AWS_REGION="us-east-1"
```
add ```aws-xray-sdk``` to ```requirements.txt``` then run ```pip install -r requirements.txt``` to install the dependencies.
Add then following to ```app.py```
```.py
#x-ray--------------------------
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.ext.flask.middleware import XRayMiddleware

#x-ray------------------
xray_url = os.getenv("AWS_XRAY_URL")
xray_recorder.configure(service='backend-flask', dynamic_naming=xray_url)
```
below ```app = Flask(__name__)``` add the following
```.py
#xray------------
XRayMiddleware(app, xray_recorder)
````
To trace the activities.home add the following
```.py
tracer = trace.get_tracer("home.activities")
```
+ setup X-ray resources by creating ```xray.json``` file to ```aws/json``` directory
```.json
{
    "SamplingRule": {
        "RuleName": "Cruddur",
        "ResourceARN": "*",
        "Priority": 9000,
        "FixedRate": 0.1,
        "ReservoirSize": 5,
        "ServiceName": "backend-flask",
        "ServiceType": "*",
        "Host": "*",
        "HTTPMethod": "*",
        "URLPath": "*",
        "Version": 1
    }
  }
```
Run the following command on the terminal
```
FLASK_ADDRESS="https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
aws xray create-group \
   --group-name "Cruddur" \
   --filter-expression "service(\"$FLASK_ADDRESS\")"
```
Then create a sampling run by running the following command.
```aws xray create-sampling-rule --cli-input-json file://aws/json/xray.json```

***Adding X-ray Deamon Service to docker compose***
```.yml
 xray-daemon:
    image: "amazon/aws-xray-daemon"
    environment:
      AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
      AWS_REGION: "us-east-1"
    command:
      - "xray -o -b xray-daemon:2000"
    ports:
      - 2000:2000/udp
```
In the backend-flask ```docker-compose.yml``` add the following env vars
```.yml
AWS_XRAY_URL: "*4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}*"
AWS_XRAY_DAEMON_ADDRESS: "xray-daemon:2000"
```
In the ```user_activities.py``` add the following code 
```.py
from aws_xray_sdk.core import xray_recorder
subsegment = xray_recorder.begin_subsegment('mock-data')
      # xray ---
      dict = {
        "now": now.isoformat(),
        "results-size": len(model['data'])
      }
      subsegment.put_metadata('key', dict, 'namespace')
      xray_recorder.end_subsegment()
    finally:  
    #  # Close the segment
      xray_recorder.end_subsegment()
```
![x-ray trace map screenshot](/_docs/assets/x-ray-instrumented.png)


