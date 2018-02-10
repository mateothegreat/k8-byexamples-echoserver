#                                 __                 __
#    __  ______  ____ ___  ____ _/ /____  ____  ____/ /
#   / / / / __ \/ __ `__ \/ __ `/ __/ _ \/ __ \/ __  /
#  / /_/ / /_/ / / / / / / /_/ / /_/  __/ /_/ / /_/ /
#  \__, /\____/_/ /_/ /_/\__,_/\__/\___/\____/\__,_/
# /____                     matthewdavis.io, holla!
#
include .make/Makefile.inc

# NS              ?= testing
# SERVICE_NAME    ?= testing-echoserver
APP             ?= $(SERVICE_NAME)
# SERVICE_PORT    ?= 80
# HOST            ?=
CERT_NAME       ?= tls-$(HOST)
CERT_FILE       ?= tls-$(HOST).crt
KEY_FILE        ?= ${HOST}.key
export

install:    guard-NS guard-HOST guard-SERVICE_NAME guard-SERVICE_PORT
delete:     guard-NS guard-HOST guard-SERVICE_NAME guard-SERVICE_PORT

## Generate and Install TLS Cert
tls: tls-generate tls-secret-create
## Generate a self-signed TLS cert
tls-generate:

	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $(KEY_FILE) -out $(CERT_FILE) -subj "/CN=$(HOST)/O=$(HOST)"

## Delete TLS Secret
tls-secret-delete:

	kubectl --namespace $(NS) delete --ignore-not-found secret $(CERT_NAME)

## Create TLS Secret from Cert
tls-secret-create: tls-secret-delete

	kubectl --namespace $(NS) create secret tls $(CERT_NAME) --key $(KEY_FILE) --cert $(CERT_FILE)

## Create htpasswd secret (make htpasswd USERNAME=user PASSWORD=changeme)
htpasswd:

	docker run --rm -it appsoa/docker-alpine-htpasswd $(USERNAME) $(PASSWORD) > auth

	kubectl --namespace $(NS) delete --ignore-not-found secret/basic-auth
	kubectl --namespace $(NS) create secret generic basic-auth --from-file=auth
