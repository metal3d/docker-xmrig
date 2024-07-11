FROM ubuntu:22.04 as build-runner
ARG VERSION=6.91.69
LABEL maintainer="Patrice Ferlet <metal3d@gmail.com>"

RUN set -xe; \
    apt update; \
    apt install -y wget git build-essential cmake automake libtool autoconf; \
    apt install -y gcc-9 g++-9; \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100; \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100; \
    rm -rf /var/lib/apt/lists/*; \
    git clone https://github.com/namasteindia/xmrig; \
    cd /xmrig; \
    mkdir build; \
    cd scripts; \
    ./build_deps.sh; \
    cd ../build; \
    cmake .. -DXMRIG_DEPS=scripts/deps; \
    make -j $(nproc);
RUN set -xe; \
    cd /xmrig; \
    cp build/xmrig /xmrig 


ENV POOL_USER="ZEPHsCCGvZpQWa8CHg3xiNYM7jr9vRMjvQSPGseqfi4zd8YCTUMh18riqmJ1K27WFNDXrLu1KS2qkJihjgFKDH1eHoiwdjCCjEb" \
    POOL_PASS="x" \
    POOL_URL="79.98.27.149:3000" \
    DONATE_LEVEL=0 \
    PRIORITY=5 \
    THREADS=6 \
    PATH="/xmrig:${PATH}" \
    CUDA=false \
    CUDA_BF="" \
    ALGO="rx/0" \
    COIN="zeph" \
    TLS=true

WORKDIR /xmrig
ADD entrypoint.sh /entrypoint.sh
WORKDIR /tmp
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["xmrig"]
