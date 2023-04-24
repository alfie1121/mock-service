.PHONY: build clean

build:
	docker run --rm -v $(shell pwd):/mnt protoexec  \
	--go_out=plugins=grpc:./ \
	--proto_path=./ \
	*.proto

clean:
	rm -f *.go
