# configuration parameters
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DATA_DIR := $(realpath $(ROOT_DIR)/../../rootfs/var/nginx/data)

SECRET_LABEL := YaaS GeoIP License Key

# requires libsecret-tools is installed
SECRET_SET := secret-tool store --label="$(SECRET_LABEL)" name "$(SECRET_LABEL)" license "Maxmind GeoIP2 License Key"
SECRET_GET := secret-tool lookup name "$(SECRET_LABEL)" license "Maxmind GeoIP2 License Key"
SECRET_DEL := secret-tool clear name "$(SECRET_LABEL)" license "Maxmind GeoIP2 License Key"

ifdef SECRET_GET
GEOIP_LICENSE_KEY := $(shell $(SECRET_GET))
endif

# docker options
VOLUMES = \
  -v $(DATA_DIR):/mnt/data \
  -v $(ROOT_DIR)/rootfs:/mnt/overlay

ENV = \
  -e MAXMIND_LICENSE_KEY="$(GEOIP_LICENSE_KEY)"

ifneq (,$(filter run start,$(firstword $(MAKECMDGOALS))))
  RUN_ARGS:=$(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@true)
endif
ifeq (,$(RUN_ARGS))
  RUN_ARGS:=$(DEF_ARGS)
endif