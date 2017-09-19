FROM elvido/alpine-nginx-lua:3.6

LABEL maintainer="elvido <ralf.hofmann@elvido.net>"

RUN echo "Updating system and installing prerequisites..." >&2 && \
    apk --no-cache upgrade --update && \
    apk --no-cache add tzdata expat-dev sqlite-dev && \
    echo "Deploying optional LUA packages..." >&2 && \
    # There is an issue with luatz 0.3-1 regarding tzfile format 3.x \
    # newer sources got injected via copy - see: rootfs/usr/lib/lua/5.1/luatz
    luarocks-deploy add "luatz" "luasocket" "luasec" "luaexpat" "luasoap" "lua-resty-http" "lua-resty-jwt" "sqlite3" "date" "libcidr-ffi" && \
    # "mobdebug" && \
    \
    echo "Cleaning up temporary files..." >&2 && \
    rm -rf /tmp/* /var/cache/apk/*

COPY rootfs /
RUN  chown -R nginx:nginx ${DEPLOYMENT_FOLDER}/*

EXPOSE 80
