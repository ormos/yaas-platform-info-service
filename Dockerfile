FROM elvido/alpine-nginx-geoip

MAINTAINER elvido <ralf.hofmann@elvido.net>

RUN echo "Updating system and installing prerequisites..." >&2 && \
    apk --no-cache upgrade --update && \
    apk --no-cache add tzdata expat-dev && \
    echo "Cleaning up caches..." >&2 && \
    rm -rf /tmp/* /var/cache/apk/*

RUN echo "Deploying optional LUA packages..." >&2 && \
    luarocks-deploy add "luatz" "luasocket" "luasec" "luaexpat" "luasoap" "lua-resty-http" && \
    # "mobdebug" && \
    \
    echo "Cleaning up temporary files..." >&2 && \
    rm -rf /tmp/* /var/cache/apk/*

COPY rootfs/var/nginx ${DEPLOYMENT_FOLDER}/

EXPOSE 80