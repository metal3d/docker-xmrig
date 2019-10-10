VERSION=3.2.0

build:
	docker build -t metal3d/xmrig:$(VERSION) --build-arg VERSION=$(VERSION) .
	docker tag metal3d/xmrig:$(VERSION) metal3d/xmrig:latest

run:
	docker run --rm -it metal3d/xmrig:$(VERSION)
