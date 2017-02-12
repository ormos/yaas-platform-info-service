ENV_FILE ?= Makefile_env.inc

ifneq ("$(wildcard $(ENV_FILE))","")
include $(ENV_FILE)
endif

NS = elvido
VERSION ?= 1.7.1
TAGS ?= latest

REPO = yaas-platform-info-data-builder
NAME = yaas-platform-info-data-builder
INSTANCE = default

.PHONY: build push shell run start stop rm release tag $(TAGS)

default: build

build:
	docker build -t $(NS)/$(REPO):$(VERSION) .

push:
	docker push $(NS)/$(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME)-$(INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/sh

run:
	docker run --rm --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

start:
	docker run -d --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	docker stop $(NAME)-$(INSTANCE)

rm:
	docker rm $(NAME)-$(INSTANCE)

release: build
	@make --no-print-directory tag -e VERSION="$(VERSION)" -e TAGS="$(TAGS)"
	@make --no-print-directory push -e VERSION="$(VERSION)"

tag: $(TAGS)

$(TAGS):
	docker tag $(NS)/$(REPO):$(VERSION) $(NS)/$(REPO):$@
