.PHONY: image all clean


REPO=cygmris/bind9-open-dnsdb
TAG=$(REPO):latest


image:
	docker build -t $(TAG) .

all: image

clean: 
	docker rmi $(TAG)
