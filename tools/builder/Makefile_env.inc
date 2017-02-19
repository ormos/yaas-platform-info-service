# configuration parameters
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DATA_DIR=$(realpath $(ROOT_DIR)/../../rootfs/var/nginx/data)

# docker options
VOLUMES = \
  -v $(DATA_DIR):/mnt/data \
  -v $(ROOT_DIR)/rootfs:/mnt/overlay

