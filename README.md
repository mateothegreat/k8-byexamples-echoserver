<!--
#                                 __                 __
#    __  ______  ____ ___  ____ _/ /____  ____  ____/ /
#   / / / / __ \/ __ `__ \/ __ `/ __/ _ \/ __ \/ __  /
#  / /_/ / /_/ / / / / / / /_/ / /_/  __/ /_/ / /_/ /
#  \__, /\____/_/ /_/ /_/\__,_/\__/\___/\____/\__,_/
# /____                     matthewdavis.io, holla!
#
#-->

[![Clickity click](https://img.shields.io/badge/k8s%20by%20example%20yo-limit%20time-ff69b4.svg?style=flat-square)](https://k8.matthewdavis.io)
[![Twitter Follow](https://img.shields.io/twitter/follow/yomateod.svg?label=Follow&style=flat-square)](https://twitter.com/yomateod) [![Skype Contact](https://img.shields.io/badge/skype%20id-appsoa-blue.svg?style=flat-square)](skype:appsoa?chat)

# Echoserver Ingress

> k8 by example -- straight to the point, simple execution.

Hook your fancy echoserver up with an ingress!
See https://github.com/mateothegreat/k8-byexamples-ingress-controller

## Usage

```sh
Usage:

  make <target>

Targets:

  install              Install Everything (ReplicationController, Service & Ingress specs)
  delete               Delete Everything (ReplicationController, Service & Ingress specs)

  install-rc           Install ReplicationController Resource
  install-service      Install Service Resource
  install-ingress      Install Ingress Resource

  logs                 Find first pod and follow log output

  tls                  Generate and Install TLS Cert
  tls-generate         Generate a self-signed TLS cert
  tls-secret-delete    Delete TLS Secret
  tls-secret-create    Create TLS Secret from Cert
```

## Example

```sh
yomateod@proliant:k8-byexamples-echoserver$ make install NS=testing

replicationcontroller "testing-echoserver" created
service "testing-echoserver" created
ingress "echomap" created

yomateod@proliant:k8-byexamples-echoserver$ make delete NS=testing

replicationcontroller "testing-echoserver" deleted
service "testing-echoserver" deleted
ingress "echomap" deleted
```

## Multi-path Test

```sh
yomateod@proliant:k8-byexamples-echoserver$ curl 35.224.113.78/anything/goes/bro -H 'Host:foo.bar.com'

CLIENT VALUES:

    client_address=10.12.0.45
    command=GET
    real path=/anything/goes/bro
    query=nil
    request_version=1.1
    request_uri=http://foo.bar.com:8080/anything/goes/bro

SERVER VALUES:

    server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:

    accept=*/*
    connection=close
    host=foo.bar.com
    user-agent=curl/7.47.0
    x-forwarded-for=10.138.36.5
    x-forwarded-host=foo.bar.com
    x-forwarded-port=80
    x-forwarded-proto=http
    x-original-uri=/anything/goes/bro
    x-real-ip=10.138.36.5
    x-scheme=http
BODY:
```

## TLS

To utilize TLS you can either supply your own cert or generate on (below).
The cert is copied into kubernetes as a secret that the ingress controller picks up.
Once installed your ingress controller will show that it has registered the cert (if all goes well):

```
I0205 23:08:37.743651       7 backend_ssl.go:64] adding secret testing/tls-foo.bar.com to the local store
```

```sh
$ make tls-generate tls-secret-create HOST=foo.bar.com

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout foo.bar.com.key -out tls-foo.bar.com.crt -subj "/CN=foo.bar.com/O=foo.bar.com"

Generating a 2048 bit RSA private key
...................................................................................................................................................................................................+++
...............+++

writing new private key to 'foo.bar.com.key'

-----

kubectl delete --ignore-not-found secret tls-foo.bar.com
kubectl create secret tls tls-foo.b

secret "tls-foo.bar.com" created
```

## Testing

```sh
$ kubectl describe ing/echomap -ntesting
Name:             echomap
Namespace:        testing
Address:          35.188.134.67
Default backend:  default-http-backend:80 (<none>)
TLS:
  tls-foo.bar.com terminates foo.bar.com
Rules:
  Host         Path  Backends
  ----         ----  --------
  foo.bar.com
               /                testing-echoserver:80 (<none>)
               /anything        testing-echoserver:80 (<none>)
               /one/two/three   testing-echoserver:80 (<none>)
  bar.baz.com
               /bar   testing-echoserver:80 (<none>)
Annotations:
Events:
  Type    Reason  Age                From                Message
  ----    ------  ----               ----                -------
  Normal  CREATE  50m                ingress-controller  Ingress testing/echomap
  Normal  UPDATE  49m                ingress-controller  Ingress testing/echomap
  Normal  CREATE  42m                ingress-controller  Ingress testing/echomap
  Normal  UPDATE  21s (x3 over 41m)  ingress-controller  Ingress testing/echoma
```

curl'in:

```sh
$ curl -vvk https://35.188.134.67 -H 'Host:foo.bar.com'
* Rebuilt URL to: https://35.188.134.67/
*   Trying 35.188.134.67...
* Connected to 35.188.134.67 (35.188.134.67) port 443 (#0)
* found 148 certificates in /etc/ssl/certs/ca-certificates.crt
* found 592 certificates in /etc/ssl/certs
* ALPN, offering http/1.1
* SSL connection using TLS1.2 / ECDHE_RSA_AES_128_GCM_SHA256
*        server certificate verification SKIPPED
*        server certificate status verification SKIPPED
*        common name: Kubernetes Ingress Controller Fake Certificate (does not match '35.188.134.67')
*        server certificate expiration date OK
*        server certificate activation date OK
*        certificate public key: RSA
*        certificate version: #3
*        subject: O=Acme Co,CN=Kubernetes Ingress Controller Fake Certificate
*        start date: Mon, 05 Feb 2018 22:33:08 GMT
*        expire date: Tue, 05 Feb 2019 22:33:08 GMT
*        issuer: O=Acme Co,CN=Kubernetes Ingress Controller Fake Certificate
*        compression: NULL
* ALPN, server accepted to use http/1.1
> GET / HTTP/1.1
> Host:foo.bar.com
> User-Agent: curl/7.47.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Server: nginx/1.13.3
< Date: Mon, 05 Feb 2018 23:16:38 GMT
< Content-Type: text/plain
< Transfer-Encoding: chunked
< Connection: keep-alive
< Strict-Transport-Security: max-age=15724800; includeSubDomains;
<
CLIENT VALUES:
client_address=10.12.1.59
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://foo.bar.com:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
connection=close
host=foo.bar.com
user-agent=curl/7.47.0
x-forwarded-for=127.0.0.1
x-forwarded-host=foo.bar.com
x-forwarded-port=443
x-forwarded-proto=https
x-original-uri=/
x-real-ip=127.0.0.1
x-scheme=https
BODY:
* Connection #0 to host 35.188.134.67 left intact
-no body in reques
```

## Dumping specs

```sh
yomateod@proliant:/mnt/c/workspace/k8/k8-byexamples-echoserver$ make dump-ingress NS=testing
envsubst < ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: echomap
  annotations:
    kubernetes.io/ingress.class: "nginx"
    # nginx.ingress.kubernetes.io/secure-backends: "true"
    # ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/rewrite-target: "/"
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /
        backend:
          serviceName: testing-echoserver
          servicePort: 80
      - path: /anything
        backend:
          serviceName: testing-echoserver
          servicePort: 80
      - path: /one/two/three
        backend:
          serviceName: testing-echoserver
          servicePort: 80
  - host: bar.baz.com
    http:
      paths:
      - path: /bar
        backend:
          serviceName: testing-echoserver
          servicePort: 80
```
