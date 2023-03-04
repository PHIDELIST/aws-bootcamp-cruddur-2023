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
 ***Dashboard screenshot***
![Honeycomb dashboard screenshot](/_docs/assets/honeycomb-dashboard.png)


