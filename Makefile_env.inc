# configuration parameters
HOST_PORT:=8089
HOST_IP:=$(shell ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# docker options
PORTS = -p $(HOST_PORT):80

VOLUMES = \
  -v $(ROOT_DIR)/files/nginx/data:/var/nginx/data \
  -v $(ROOT_DIR)/files/nginx/lua:/var/nginx/lua \
  -v $(ROOT_DIR)/files/nginx/config/nginx.conf:/var/nginx/config/nginx.conf

ENV = \
  -e DEBUG_HOST_ADDR="$(HOST_IP)" \
  -e DEBUG_EXTERNAL_URL="http://localhost:$(HOST_PORT)"