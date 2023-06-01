#!/bin/bash

mkdir certs

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=flask' -keyout certs/flask.key -out certs/flask.crt
openssl req -out certs/flask.flask.csr -newkey rsa:2048 -nodes -keyout certs/flask.flask.key -subj "/CN=flask.flask/O=app organization"
openssl x509 -req -sha256 -days 365 -CA certs/flask.crt -CAkey certs/flask.key -set_serial 0 -in certs/flask.flask.csr -out certs/flask.flask.crt
openssl req -out certs/flask.flask.csr -newkey rsa:2048 -nodes -keyout certs/flask.flask.key -subj "/CN=flask.flask/O=client organization"
openssl x509 -req -sha256 -days 365 -CA certs/flask.crt -CAkey certs/flask.key -set_serial 1 -in certs/flask.flask.csr -out certs/flask.flask.crt

#remove old JIC
minikube kubectl -- -n istio-system delete secret my-credential

minikube kubectl -- create -n istio-system secret generic my-credential --from-file=tls.key=certs/flask.flask.key --from-file=tls.crt=certs/flask.flask.crt --from-file=ca.crt=certs/flask.crt