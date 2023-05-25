# PPRP

This is a simple 2-component app with mTLS authorization.
It is task1 app, but has mTLS.
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

* Make certifiactes: 
```bash
./make_certs.sh
```

* When done, run `minikube delete`.

### How to Query

#### Proper IP

To perform a query, you need to know the IP address/port of ingress service.
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

You need the line with `https/443`. In our case, the address is `http://192.168.49.2:30332`.

#### Query
Let's query this address. `/facts/cat/1` endpoint is hard-coded in nginx.
Example query can be found in `curl_query.sh`.

To use it, you need to export `SECURE_INGRESS_PORT` and `INGRESS_HOST`. In our case it is `30332` and `192.168.49.2`.


```bash
export INGRESS_HOST=192.168.49.2
export SECURE_INGRESS_PORT=30332

curl -v -HHost:flask.flask --resolve "flask.flask:$SECURE_INGRESS_PORT:$INGRESS_HOST"   --cacert certs/flask.crt --cert certs/flask.flask.crt --key certs/flask.flask.key   "https://flask.flask:$SECURE_INGRESS_PORT/facts/cat/1"


* Added flask.flask:31966:192.168.49.2 to DNS cache
* Hostname flask.flask was found in DNS cache
*   Trying 192.168.49.2:31966...
* Connected to flask.flask (192.168.49.2) port 31966 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
*  CAfile: certs/flask.crt
*  CApath: /etc/ssl/certs
* TLSv1.0 (OUT), TLS header, Certificate Status (22):
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS header, Certificate Status (22):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS header, Finished (20):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Request CERT (13):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.2 (OUT), TLS header, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.3 (OUT), TLS handshake, Certificate (11):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.3 (OUT), TLS handshake, CERT verify (15):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server accepted to use h2
* Server certificate:
*  subject: CN=flask.flask; O=client organization
*  start date: May 25 19:29:13 2023 GMT
*  expire date: May 24 19:29:13 2024 GMT
*  common name: flask.flask (matched)
*  issuer: O=example Inc.; CN=flask
*  SSL certificate verify ok.
* Using HTTP2, server supports multiplexing
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* Using Stream ID: 1 (easy handle 0x55f549fbde90)
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
> GET /facts/cat/1 HTTP/2
> Host:flask.flask
> user-agent: curl/7.81.0
> accept: */*
> 
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* Connection state changed (MAX_CONCURRENT_STREAMS == 2147483647)!
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
< HTTP/2 200 
< server: istio-envoy
< date: Thu, 25 May 2023 19:29:31 GMT
< content-type: application/json; charset=utf-8
< content-length: 337
< x-powered-by: Express
< access-control-allow-origin: *
< etag: W/"151-AJjQw/ZdG00PqmMoua17Vn1Z5E0"
< set-cookie: connect.sid=s%3AMPAxIsgQM8OycSJiTRyGuZ9yVSrnc_vt.lFiFX8%2BOm8NWBgnZUBoQiJUsBj%2BXcohbHhsDZEtQJeM; Path=/; HttpOnly
< via: 1.1 vegur
< x-envoy-upstream-service-time: 514
< 
* Connection #0 to host flask.flask left intact
{"status":{"verified":null,"sentCount":0},"_id":"6408554ece979a6559211db9","user":"64033713ec62a9dbd6132aaa","text":"Felines have working, short-term, and long-term memory like other animals and actually remember people.","type":"cat","deleted":false,"createdAt":"2023-03-08T09:28:46.557Z","updatedAt":"2023-03-08T09:28:46.557Z","__v":0}
```
