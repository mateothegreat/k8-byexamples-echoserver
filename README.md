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
