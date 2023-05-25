# PPRP

This is a simple 2-component app.

---

## API

Public API chosen: http://cat-fact.herokuapp.com/facts/random  
Params:
`animal_type`: type of animal, possible values: `cat`, `dog`
`amount`: amount of returned facts

API query example: 

```bash
curl http://cat-fact.herokuapp.com/facts/random?animal_type=cat&amount=1

{"status":{"verified":null,"sentCount":0},"_id":"6254b6f85191a7b075998e4d","user":"6254b6d55191a7b075998e40","text":"My cat drink water with his paws.","type":"cat","deleted":false,"createdAt":"2022-04-11T23:17:12.737Z","updatedAt":"2022-04-11T23:17:12.737Z","__v":0}
```

---

## Structure

There are running 2 microservices: 
* Simple Flask server that queries external API mentioned above,
* Nginx as a reverse (client-facing) proxy.

---

## HowTo
### Prerequisites
* Install Kubernetes (e.g. [minikube](https://minikube.sigs.k8s.io/docs/start/) )

* Prepare minikube: 
```bash
minikube start --driver=docker --memory 4096
```

* Run: 
```bash
./run.sh
```
The `run.sh` script also downloads and applies latest Istio.
It also does `minikube tunnel`, which will require you to enter sudo password.

* To terminate the process:
  - Press `Ctrl+c`
  - Run `minikube delete`.

### How to Query

#### Proper IP

To perform a query, you need to know the IP address of ingress service.
To do this, run `minikube service list`. The output will be something like:
```
|--------------|----------------------|-------------------|---------------------------|
|  NAMESPACE   |         NAME         |    TARGET PORT    |            URL            |
|--------------|----------------------|-------------------|---------------------------|
| default      | flask-cip            | No node port      |                           |
| default      | kubernetes           | No node port      |                           |
| default      | nginx-cip            | No node port      |                           |
| istio-system | istio-egressgateway  | No node port      |                           |
| istio-system | istio-ingressgateway | status-port/15021 | http://192.168.49.2:31282 |
|              |                      | http2/80          | http://192.168.49.2:30622 |
|              |                      | https/443         | http://192.168.49.2:30332 |
|              |                      | tcp/31400         | http://192.168.49.2:32590 |
|              |                      | tls/15443         | http://192.168.49.2:31034 |
| istio-system | istiod               | No node port      |                           |
| kube-system  | kube-dns             | No node port      |                           |
|--------------|----------------------|-------------------|---------------------------|
```

You need the line with `http2/80`. In our case, the address is `http://192.168.49.2:30622`.

#### Query
Let's query this address. `/cat/1` endpoint is hard-coded in nginx, so the query shall look like this:
```bash
curl http://192.168.49.2:30622/cat/1

{"status":{"verified":null,"sentCount":0},"_id":"627410aba659431711fd5ba9","user":"6268ea344514425908fd37c8","text":"Новый факт о кошках, придумай сам ага.","type":"cat","deleted":false,"createdAt":"2022-05-05T18:00:11.882Z","updatedAt":"2022-05-05T18:00:11.882Z","__v":0}
```
