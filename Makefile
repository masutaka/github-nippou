NAME := github-nippou
SRCS := $(shell find . -type f -name '*.go')

all: build

.PHONY: dep
dep:
ifeq ($(shell command -v dep 2> /dev/null),)
	go get github.com/golang/dep/cmd/dep
endif

.PHONY: go-bindata
go-bindata:
ifeq ($(shell command -v go-bindata 2> /dev/null),)
	go get github.com/jteeuwen/go-bindata/...
endif

.PHONY: deps
deps: dep go-bindata
	dep ensure
	go-bindata -nocompress -pkg lib -o lib/bindata.go config

.PHONY: build
build: $(SRCS)
	go build -v -o $(NAME)

.PHONY: install
install:
	go install

.PHONY: clean
clean:
	go clean
	rm -f $(NAME)
	rm -rf dist/*

.PHONY: test
test:
	go test -v ./...

.PHONY: cross-build
cross-build: deps
	for os in darwin linux windows; do \
		for arch in amd64; do \
			GOOS=$$os GOARCH=$$arch CGO_ENABLED=0 go build -v -o dist/$(NAME)_$${os}_$${arch}; \
		done; \
	done
