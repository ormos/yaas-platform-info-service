# configuration parameters
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
GEOIP_DIR=$(realpath $(ROOT_DIR)/../../rootfs/var/nginx/data/geoip)

# docker options
VOLUMES = \
  -v $(GEOIP_DIR):/mnt/geoip \
  -v $(ROOT_DIR)/rootfs:/mnt/overlay

