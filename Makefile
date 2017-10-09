NAME := github-nippou
SRCS := $(shell find . -type f ! -path ./lib/bindata.go -name '*.go')
CONFIGS := $(wildcard config/*)
VERSION := v$(shell grep 'const Version ' lib/version.go | sed -E 's/.*"(.+)"$$/\1/')

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

.PHONY: gox
gox:
ifeq ($(shell command -v gox 2> /dev/null),)
	go get github.com/mitchellh/gox
endif

.PHONY: ghr
ghr:
ifeq ($(shell command -v ghr 2> /dev/null),)
	go get github.com/tcnksm/ghr
endif

.PHONY: deps
deps: dep go-bindata gox ghr
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

.PHONY: test
test:
	go test -v ./...

.PHONY: cross-build
cross-build: deps lib/bindata.go
	rm -rf pkg/*
	gox -os="darwin linux windows" -arch="amd64 386" -output "pkg/{{.OS}}_{{.Arch}}/{{.Dir}}"

.PHONY: package
package: cross-build
	if [ -d pkg ]; then \
		rm -rf pkg/dist; \
	fi

	mkdir -p pkg/dist/$(VERSION)

	for PLATFORM in $$(find pkg -mindepth 1 -maxdepth 1 -type d); do \
		PLATFORM_NAME=$$(basename $${PLATFORM}); \
		ARCHIVE_NAME=$(NAME)_$(VERSION)_$${PLATFORM_NAME}; \
		pushd $${PLATFORM}; \
		zip $(CURDIR)/pkg/dist/$(VERSION)/$${ARCHIVE_NAME}.zip *; \
		popd; \
	done

	pushd pkg/dist/$(VERSION); \
	shasum -a 256 * > $(VERSION)_SHASUMS; \
	popd

.PHONY: release
release:
	ghr $(VERSION) pkg/dist/$(VERSION)
