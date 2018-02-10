#                                 __                 __
#    __  ______  ____ ___  ____ _/ /____  ____  ____/ /
#   / / / / __ \/ __ `__ \/ __ `/ __/ _ \/ __ \/ __  /
#  / /_/ / /_/ / / / / / / /_/ / /_/  __/ /_/ / /_/ /
#  \__, /\____/_/ /_/ /_/\__,_/\__/\___/\____/\__,_/
# /____                     matthewdavis.io, holla!
#

NS              ?= infra
SERVICE_NAME    ?= testing-echoserver
APP             ?= testing-echoserver
SERVICE_PORT    ?= 80
HOST            ?= foo.bar.com
CERT_NAME       ?= tls-$(HOST)
CERT_FILE       ?= tls-$(HOST).crt
KEY_FILE        ?= ${HOST}.key
export

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
