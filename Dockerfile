FROM ormos/alpine-nginx-lua:3.8

LABEL maintainer="ormos <r.hofmann@sap.com>"

RUN echo "Updating system and installing prerequisites..." >&2 && \
    apk --no-cache upgrade --update && \
    apk --no-cache add tzdata expat-dev sqlite-dev && \
    \
    echo "Apply temporary patch for LuaJIT to file ${LUA_INC}/lua.h : LUA_VERSION 502" >&2 && \
    sed -ie 's/#define LUA_VERSION_NUM	501/#define LUA_VERSION_NUM	502/g' "${LUA_INC}/lua.h" && \
    \
    echo "Deploying optional LUA packages..." >&2 && \
    luarocks-deploy add "luatz" "luasocket" "luasec" "luaexpat" "luasoap" "lua-resty-http" "lua-resty-jwt" "sqlite3" "date" "libcidr-ffi" && \
    # "mobdebug" && \
    \
    echo "Cleaning up temporary files..." >&2 && \
    rm -rf /tmp/* /var/cache/apk/*

COPY rootfs /
RUN  chown -R nginx:nginx ${DEPLOYMENT_FOLDER}/*

EXPOSE 80
