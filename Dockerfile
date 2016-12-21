FROM elvido/alpine-nginx-geoip

MAINTAINER elvido <ralf.hofmann@elvido.net>

RUN echo "Updating system and installing prerequisites..." >&2 && \
    apk --no-cache upgrade --update && \
    apk --no-cache add tzdata expat-dev sqlite-dev && \
    echo "Cleaning up caches..." >&2 && \
    rm -rf /tmp/* /var/cache/apk/*

RUN echo "Deploying optional LUA packages..." >&2 && \
    # There is an issue with luatz 0.3-1 regarding tzfile format 3.x \
    # newer sources got injected via copy - see: rootfs/usr/lib/lua/5.1/luatz
    luarocks-deploy add "luatz" "luasocket" "luasec" "luaexpat" "luasoap" "lua-resty-http" "sqlite3" && \
    # "mobdebug" && \
    \
    echo "Cleaning up temporary files..." >&2 && \
    rm -rf /tmp/* /var/cache/apk/*

COPY rootfs /

EXPOSE 80