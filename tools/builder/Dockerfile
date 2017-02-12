FROM elvido/alpine

MAINTAINER elvido <ralf.hofmann@elvido.net>

ENV DATA_FOLDER="/mnt/geoip"

RUN apk --no-cache upgrade --update && \
    apk --no-cache add --quiet ca-certificates g++ libxml2 libxml2-dev openssl openssl-dev tar curl wget make zlib sqlite libmaxminddb perl perl-dev perl-net-ssleay perl-net-ip perl-net-cidr perl-net-dns perl-net-ipv4addr build-base gnupg expat expat-dev && \
    \
    mkdir -p "${DATA_FOLDER}" && \
    \
    curl -L https://cpanmin.us | perl - App::cpanminus && \
    \
    cpanm -n Devel::Refcount MaxMind::DB::Reader::XS MaxMind::DB::Writer::Tree Net::Works::Network GeoIP2 Data::Printer || : && \
    \
    echo "Cleaning up..." >&2 && \
    rm -rf ./cpanm /root/.cpanm && \
    rm -rf /tmp/* /var/cache/apk/*

COPY rootfs /

VOLUME ["${DATA_FOLDER}"]