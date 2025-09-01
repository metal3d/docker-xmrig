FROM ubuntu:22.04 as build-cuda-plugin
LABEL maintainer="Patrice Ferlet <metal3d@gmail.com>"

RUN set -xe; \
  apt-get update; \
  apt-get install --no-install-recommends -y \
  nvidia-cuda-toolkit wget build-essential cmake automake libtool autoconf gcc g++ ca-certificates;

ARG CUDA_PLUGIN_VERSION="6.22.1"
RUN set -xe; \
  wget -q -nv https://github.com/xmrig/xmrig-cuda/archive/refs/tags/v${CUDA_PLUGIN_VERSION}.tar.gz; \
  tar xf v${CUDA_PLUGIN_VERSION}.tar.gz; \
  mv xmrig-cuda-${CUDA_PLUGIN_VERSION} /xmrig-cuda; \
  mkdir -p /xmrig-cuda/build

ARG CUDA_VERSION="11.5"
WORKDIR /xmrig-cuda/build
RUN set -xe; \
  cmake .. \
  -DCUDA_LIB=/usr/lib/x86_64-linux-gnu/stubs/libcuda.so \
  -DCUDA_TOOLKIT_ROOT_DIR=/usr/lib/x86_64-linux-gnu \
  -DCUDA_VERSION=${CUDA_VERSION}; \
  make -j "$(nproc)";


FROM ubuntu:22.04 as build-runner
LABEL maintainer="Patrice Ferlet <metal3d@gmail.com>"
RUN set -xe; \
  apt-get update; \
  apt-get install --no-install-recommends -y wget build-essential cmake automake libtool autoconf gcc g++ ca-certificates;

ARG XMRIG_VERSION=6.24.0
RUN set -xe; \
  wget -q -nv https://github.com/xmrig/xmrig/archive/refs/tags/v${XMRIG_VERSION}.tar.gz; \
  tar xf v${XMRIG_VERSION}.tar.gz; \
  mv "xmrig-${XMRIG_VERSION}" /xmrig; \
  mkdir -p /xmrig/build


WORKDIR /xmrig/scripts
RUN set -xe; \
  ./build_deps.sh;

WORKDIR /xmrig/build
RUN set -xe; \
  cmake .. -DXMRIG_DEPS=scripts/deps; \
  make -j "$(nproc)"; \
  cp xmrig ..

FROM ubuntu:22.04 as runner
LABEL maintainer="Patrice Ferlet <metal3d@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/metal3d/docker-xmrig"
LABEL org.opencontainers.image.description="XMRig miner with CUDA support on Docker, Podman, Kubernetes..."
LABEL org.opencontainers.image.licenses="MIT"
RUN set -xe; \
  mkdir /xmrig; \
  apt-get update; \
  apt-get -y install --no-install-recommends jq libnvidia-compute-535 libnvrtc11.2 ca-certificates; \
  rm -rf /var/lib/apt/lists/*
COPY --from=build-runner /xmrig/xmrig /xmrig/xmrig
COPY --from=build-runner /xmrig/src/config.json /xmrig/config.json
COPY --from=build-cuda-plugin /xmrig-cuda/build/libxmrig-cuda.so /usr/local/lib/


ENV POOL_USER="44vjAVKLTFc7jxTv5ij1ifCv2YCFe3bpTgcRyR6uKg84iyFhrCesstmWNUppRCrxCsMorTP8QKxMrD3QfgQ41zsqMgPaXY5" \
  POOL_PASS="" \
  POOL_URL="xmr.k8s.metal3d.org:8080" \
  DONATE_LEVEL=5 \
  PRIORITY=0 \
  THREADS=0 \
  PATH="/xmrig:${PATH}" \
  CUDA=false \
  CUDA_BF="" \
  ALGO="" \
  COIN="" \
  THREAD_DIVISOR="2"

WORKDIR /xmrig
COPY entrypoint.sh /entrypoint.sh
WORKDIR /tmp
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["xmrig"]
