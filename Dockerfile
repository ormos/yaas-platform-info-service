FROM elvido/alpine-nginx-geoip

MAINTAINER elvido <ralf.hofmann@elvido.net>

RUN apk --no-cache upgrade --update && \
    \
    echo "Deploying optional LUA packages..." >&2 && \
    luarocks-deploy add "luatz" && \
    \
    echo "Cleaning up..." >&2 && \
    rm -rf /tmp/* /var/cache/apk/*

COPY files/nginx ${DEPLOYMENT_FOLDER}/

EXPOSE 80