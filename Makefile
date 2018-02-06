#                                 __                 __
#    __  ______  ____ ___  ____ _/ /____  ____  ____/ /
#   / / / / __ \/ __ `__ \/ __ `/ __/ _ \/ __ \/ __  /
#  / /_/ / /_/ / / / / / / /_/ / /_/  __/ /_/ / /_/ /
#  \__, /\____/_/ /_/ /_/\__,_/\__/\___/\____/\__,_/
# /____                     matthewdavis.io, holla!
#

NS              ?= testing
SERVICE_NAME    ?= testing-echoserver
APP             ?= testing-echoserver
SERVICE_PORT    ?= 80
HOST            ?= foo.bar.com
CERT_NAME       ?= tls-$(HOST)
CERT_FILE       ?= tls-$(HOST).crt
KEY_FILE        ?= ${HOST}.key

export

all:        help

## Install Everything (ReplicationController, Service & Ingress specs)
install:    install-replication-controller install-service install-ingress
## Delete Everything (ReplicationController, Service & Ingress specs)
delete:     delete-replication-controller delete-service delete-ingress

## Install ReplicationController Resource
install-rc: install-replication-controller
## Install Service Resource
install-service: install-service
## Install Ingress Resource
# install-ingress: install-ingress

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

# LIB
install-%:
	@envsubst < manifests/$*.yaml | kubectl --namespace $(NS) apply -f -

delete-%:
	@envsubst < manifests/$*.yaml | kubectl --namespace $(NS) delete --ignore-not-found -f -

status-%:
	@envsubst < manifests/$*.yaml | kubectl --namespace $(NS) rollout status -w -f -

dump-%:
	envsubst < manifests/$*.yaml
## Find first pod and follow log output
logs:
	kubectl --namespace $(NS) logs -f $(shell kubectl get pods --all-namespaces -lapp=$(APP) -o jsonpath='{.items[0].metadata.name}')

# Help Outputs
GREEN  		:= $(shell tput -Txterm setaf 2)
YELLOW 		:= $(shell tput -Txterm setaf 3)
WHITE  		:= $(shell tput -Txterm setaf 7)
RESET  		:= $(shell tput -Txterm sgr0)
help:

	@echo "\nUsage:\n\n  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}\n\nTargets:\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-20s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo
# EOLIB
