VERSION = 6.24.0
CUDA_PLUGIN_VERSION=6.22.1
CUDA_VERSION=11.5
REL = $(VERSION)-local
THREADS = $(shell nproc)
PRIORITY = 0
REPO=ghcr.io/metal3d/xmrig
CC=podman


all: build run

build:
	$(CC) build -t $(REPO):$(REL) \
		--build-arg XMRIG_VERSION=$(VERSION) \
		--build-arg CUDA_PLUGIN_VERSION=$(CUDA_PLUGIN_VERSION) \
		--build-arg CUDA_VERSION=$(CUDA_VERSION) \
	.
	$(CC) tag $(REPO):$(REL) $(REPO):latest

run: build
	$(CC) run --rm -it -e THREADS=$(THREADS) -e PRIORITY=$(PRIORITY) $(REPO):$(REL)

run-cuda: build
	$(CC) run \
		--device nvidia.com/gpu=all \
		--device /dev/cpu \
		--device /dev/cpu_dma_latency \
		--security-opt=label=disable \
		--rm -it \
		--cap-add=ALL \
		--privileged \
		-e THREADS=$(THREADS) \
		-e PRIORITY=$(PRIORITY) \
		-e CUDA=true \
		-e NO_CPU=true \
		$(REPO):$(REL)
