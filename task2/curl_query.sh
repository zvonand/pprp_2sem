#!/bin/bash

curl -v -HHost:flask.flask --resolve "flask.flask:$SECURE_INGRESS_PORT:$INGRESS_HOST" --cacert certs/flask.crt --cert certs/flask.flask.crt --key certs/flask.flask.key "https://flask.flask:$SECURE_INGRESS_PORT/facts/cat/1"