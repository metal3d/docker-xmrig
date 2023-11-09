VERSION = 6.20.0
CUDA_PLUGIN_VERSION=6.17.0
CUDA_VERSION=11-4
REL = $(VERSION)-local
THREADS = $(shell nproc)
PRIORITY = 0
REPO=docker.io/metal3d/xmrig
CC=podman

HUB=https://hub.docker.com/v2

all: build run

build:
	$(CC) build -t $(REPO):$(REL) --build-arg VERSION=$(VERSION) .
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
