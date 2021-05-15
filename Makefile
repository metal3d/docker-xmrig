VERSION = 6.12.1
REL = $(VERSION)-1
THREADS = $(shell nproc)
PRIORITY = 0
REPO=metal3d/xmrig

HUB=https://hub.docker.com/v2

all: build run

build:
	docker build -t $(REPO):$(REL) --build-arg VERSION=$(VERSION) .
	docker tag $(REPO):$(REL) $(REPO):latest

run:
	docker run --rm -it -e THREADS=$(THREADS) -e PRIORITY=$(PRIORITY) $(REPO):$(REL)


deploy: build
	docker push $(REPO):$(REL)
	docker push $(REPO):latest

test:

.ONESHELL:
set-description:
ifdef PASSWORD
	@echo "Changing description"
	token=`http $(HUB)/users/login username=$(USERNAME) password=$(PASSWORD) | jq -r '.token'`
	http --form PATCH  $(HUB)/repositories/metal3d/xmrig/ Authorization:"JWT $$token" full_description=@README.md 
else
	@echo "You need to provide repo password in PASSWORD variable argument"
endif
