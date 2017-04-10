ENV_FILE ?= Makefile_env.inc

ifneq ("$(wildcard $(ENV_FILE))","")
include $(ENV_FILE)
endif

NS = elvido
VERSION ?= 1.9.4
TAGS ?= latest

REPO = yaas-platform-info-service
NAME = yaas-platform-info-service
INSTANCE = default

API_CONSOLE = $(ROOT_DIR)/rootfs/var/nginx/assets/api-console
DATA_CONSOLE = $(ROOT_DIR)/rootfs/var/nginx/assets/data-console

GEOIP_NETWORKS = $(ROOT_DIR)/rootfs/var/nginx/data/geoip

.PHONY: clean build push shell run start stop rm release tag api-console data-console geoip-networks $(TAGS)

default: build

api-console: $(API_CONSOLE)

$(API_CONSOLE): TMP_FOLDER := $(shell mktemp -d)
$(API_CONSOLE):
	mkdir -p $@
	cd $(TMP_FOLDER) ; wget -qO- https://github.com/mulesoft/api-console/archive/master.zip | bsdtar -xvf- api-console-master/dist/
	rm -rf $(TMP_FOLDER)/api-console-master/dist/examples
	cp -r $(TMP_FOLDER)/api-console-master/dist/* $@
	rm -rf $(TMP_FOLDER)
	uglifyjs --compress --source-map $@/scripts/api-console.min.js.map --output $@/scripts/api-console.min.js -- $@/scripts/api-console.js
	uglifyjs --compress --source-map $@/scripts/api-console-vendor.min.js.map --output $@/scripts/api-console-vendor.min.js -- $@/scripts/api-console-vendor.js
	sed -e 's|<raml-initializer></raml-initializer>|<raml-console-loader src="../meta-data/api.raml" options="{ disableRamlClientGenerator: true, resourcesCollapsed: true}"></raml-console-loader>|' -i $@/index.html
	sed -e 's|api-console.js|api-console.min.js|' -i $@/index.html
	sed -e 's|api-console-vendor.js|api-console-vendor.min.js|' -i $@/index.html

data-console: $(DATA_CONSOLE)

$(DATA_CONSOLE): TMP_FOLDER := $(shell mktemp -d)
$(DATA_CONSOLE):
	mkdir -p $@
	cd $(TMP_FOLDER) ; wget -qO- https://github.com/jdorn/json-editor/archive/master.zip | bsdtar -xvf- json-editor-master/dist/
	cp -r $(TMP_FOLDER)/json-editor-master/dist/* $@
	rm -rf $(TMP_FOLDER)

geoip-networks: $(GEOIP_NETWORKS)

$(GEOIP_NETWORKS):
	mkdir -p $@
	make -C $(ROOT_DIR)/tools/builder --no-print-directory build
	make -C $(ROOT_DIR)/tools/builder --no-print-directory run

clean:
	rm -rf $(API_CONSOLE)
	rm -rf $(DATA_CONSOLE)
	rm -rf $(GEOIP_NETWORKS)

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


