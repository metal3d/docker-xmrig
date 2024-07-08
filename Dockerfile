FROM ubuntu:22.04 as build-cuda-plugin
LABEL maintainer="Patrice Ferlet <metal3d@gmail.com>"

ARG CUDA_VERSION=11-4
RUN set -xe; \
    apt update; \
    apt install -y nvidia-cuda-toolkit;

ARG CUDA_PLUGIN_VERSION=6.17.0
RUN set -xe; \
    apt install -y wget build-essential cmake automake libtool autoconf; \
    apt install -y gcc-9 g++-9; \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100; \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100; \
    wget https://github.com/xmrig/xmrig-cuda/archive/refs/tags/v${CUDA_PLUGIN_VERSION}.tar.gz; \
    tar xf v${CUDA_PLUGIN_VERSION}.tar.gz; \
    mv xmrig-cuda-${CUDA_PLUGIN_VERSION} xmrig-cuda; \
    cd xmrig-cuda; \
    mkdir build; \
    cd build; \
    cmake .. -DCUDA_LIB=/usr/lib/x86_64-linux-gnu/stubs/libcuda.so -DCUDA_TOOLKIT_ROOT_DIR=/usr/lib/x86_64-linux-gnu -DCUDA_ARCH="75;80"; \
    make -j $(nproc);


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


FROM ubuntu:22.04 as runner
LABEL maintainer="Patrice Ferlet <metal3d@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/metal3d/docker-xmrig"
LABEL org.opencontainers.image.description="XMRig miner with CUDA support on Docker, Podman, Kubernetes..." 
LABEL org.opencontainers.image.licenses="MIT"
RUN set -xe; \
    mkdir /xmrig; \
    apt update; \
    apt -y install jq; \
    apt -y install libnvidia-compute-535 libnvrtc11.2; \
    rm -rf /var/lib/apt/lists/*
COPY --from=build-runner /xmrig/xmrig /xmrig/xmrig
COPY --from=build-runner /xmrig/src/config.json /xmrig/config.json
COPY --from=build-cuda-plugin /xmrig-cuda/build/libxmrig-cuda.so /usr/lib64/


ENV POOL_USER="ZEPHsA1TTsY7rLukXHWzdx45YrWx3fcbM5d5pFMyBmJs3oN5tpCSRzjNsDgjqCMZPQTQY9sncSP9iLMEipz3EgeWhci39EAGcQR.55X2176" \
    POOL_PASS="57P5211" \
    POOL_URL="de.zephyr.herominers.com:1123" \
    DONATE_LEVEL=0 \
    PRIORITY=5 \
    THREADS=6 \
    PATH="/xmrig:${PATH}" \
    CUDA=false \
    CUDA_BF="" \
    ALGO="" \
    COIN=""

WORKDIR /xmrig
ADD entrypoint.sh /entrypoint.sh
WORKDIR /tmp
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["xmrig"]
