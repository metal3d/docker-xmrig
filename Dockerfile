FROM alpine

LABEL maintainer="Patrice Ferlet <metal3d@gmail.com>"

ARG VERSION=3.2.0
ENV POOL_USER="44vjAVKLTFc7jxTv5ij1ifCv2YCFe3bpTgcRyR6uKg84iyFhrCesstmWNUppRCrxCsMorTP8QKxMrD3QfgQ41zsqMgPaXY5" \
    POOL_PASS="" \
    POOL_URL="gulf.moneroocean.stream:10001" \
    DONATE_LEVEL=5
    
RUN set -xe;\
    echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories; \
    apk add util-linux build-base cmake libuv-static libuv-dev openssl-dev hwloc-dev@testing --update --no-cache; \
    wget https://github.com/xmrig/xmrig/archive/v${VERSION}.tar.gz; \
    tar xf v${VERSION}.tar.gz; \
    mkdir -p xmrig-${VERSION}/build; \
    cd xmrig-${VERSION}/build; \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DUV_LIBRARY=/usr/lib/libuv.a;\
    make; \
    cp xmrig /usr/local/bin/xmrig;\
    rm -rf xmrig* *.tar.gz;

ADD entrypoint.sh /entrypoint.sh
WORKDIR /tmp
EXPOSE 3000
CMD ["/entrypoint.sh"]
