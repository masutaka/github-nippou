NAME := github-nippou
SRCS := $(shell find . -type f ! -path ./lib/bindata.go -name '*.go')
CONFIGS := $(wildcard config/*)

all: $(NAME)

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

lib/bindata.go: $(CONFIGS)
	go-bindata -nocompress -pkg lib -o lib/bindata.go config

$(NAME): lib/bindata.go $(SRCS)
	go build -o $(NAME)

.PHONY: install
install:
	go install

.PHONY: clean
clean:
	rm -f $(NAME)
	rm -rf dist/*

.PHONY: test
test:
	go test -v ./...

.PHONY: cross-build
cross-build: deps lib/bindata.go
	for os in darwin linux windows; do \
		for arch in amd64 386; do \
			GOOS=$$os GOARCH=$$arch CGO_ENABLED=0 go build -o dist/$(NAME); \
			gzip -c dist/$(NAME) > dist/$(NAME)_$${os}_$${arch}.gz; \
			rm -f dist/$(NAME); \
			shasum -a 256 dist/$(NAME)_$${os}_$${arch}.gz; \
		done; \
	done
