VERSION = 3.2.0
REL = $(VERSION)-2
THREADS = $(shell nproc)
PRIORITY = 0


all: build run

build:
	docker build -t metal3d/xmrig:$(REL) --build-arg VERSION=$(VERSION) .
	docker tag metal3d/xmrig:$(REL) metal3d/xmrig:latest

run:
	docker run --rm -it -e THREADS=$(THREADS) -e PRIORITY=$(PRIORITY) metal3d/xmrig:$(REL)
