#!/bin/bash

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.17.2 sh -
cd istio-1.17.2
export PATH=$PWD/bin:$PATH

istioctl manifest apply --set profile=demo -y
istioctl install --set profile=demo --set meshConfig.outboundTrafficPolicy.mode=REGISTRY_ONLY -y
cd ..

kubectl label namespace default istio-injection=enabled

kubectl apply -f flask/k8s/service.yml 
kubectl apply -f k8s/ingress/gateway.yml
kubectl apply -f k8s/egress/gateway.yml
kubectl apply -f k8s/nginx/service.yml

minikube tunnel
