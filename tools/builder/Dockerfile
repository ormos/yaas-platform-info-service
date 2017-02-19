FROM elvido/alpine

MAINTAINER elvido <ralf.hofmann@elvido.net>

ENV DATA_FOLDER="/mnt/data"

RUN apk --no-cache upgrade --update && \
    apk --no-cache add --quiet ca-certificates g++ libxml2 libxml2-dev openssl openssl-dev tar curl wget libarchive-tools make zlib sqlite libmaxminddb libmaxminddb-dev perl perl-dev perl-net-ssleay perl-net-ip perl-net-cidr perl-net-dns perl-net-ipv4addr build-base gnupg expat expat-dev && \
    \
    mkdir -p "${DATA_FOLDER}" && \
    \
    curl -jkSL -# https://cpanmin.us | perl - App::cpanminus && \
    \
    cpanm -n Devel::Refcount MaxMind::DB::Reader::XS MaxMind::DB::Writer::Tree Net::Works::Network GeoIP2 Data::Printer File::Basename File::chown DateTime::Format::ISO8601 DBD::SQLite JSON || : && \
    \
    echo "Cleaning up..." >&2 && \
    rm -rf ./cpanm /root/.cpanm && \
    rm -rf /tmp/* /var/cache/apk/*

COPY rootfs /

VOLUME ["${DATA_FOLDER}"]