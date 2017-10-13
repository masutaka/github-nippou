NAME := github-nippou
SRCS := $(shell find . -type f ! -path ./lib/bindata.go -name '*.go')
CONFIGS := $(wildcard config/*)
VERSION := v$(shell grep 'const Version ' lib/version.go | sed -E 's/.*"(.+)"$$/\1/')
PACKAGES := $(shell go list ./...)

all: $(NAME)

# Install dependencies for development
.PHONY: deps
deps: dep go-bindata
	dep ensure

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

# Build binary
$(NAME): lib/bindata.go $(SRCS)
	go build -o $(NAME)

lib/bindata.go: go-bindata $(CONFIGS)
	go-bindata -nocompress -pkg lib -o lib/bindata.go config

# Install binary to $GOPATH/bin
.PHONY: install
install:
	go install

# Clean binary
.PHONY: clean
clean:
	rm -f $(NAME)
	rm -f lib/bindata.go

# Test for development
.PHONY: test
test: lib/bindata.go
	go test -v $(PACKAGES)

# Test for CI
.PHONY: test-all
test-all: deps-ci vet lint test

.PHONY: deps-ci
deps-ci: dep golint lib/bindata.go
	dep ensure

.PHONY: golint
golint:
ifeq ($(shell command -v golint 2> /dev/null),)
	go get github.com/golang/lint/golint
endif

.PHONY: vet
vet:
	go vet $(PACKAGES)

.PHONY: lint
lint:
	echo $(PACKAGES) | xargs -n1 golint -set_exit_status

# Generate binary archives for GitHub release
.PHONY: dist
dist: cross-build
	if [ -d pkg ]; then \
		rm -rf pkg/dist; \
	fi

	mkdir -p pkg/dist/$(VERSION)

	for PLATFORM in $$(find pkg -mindepth 1 -maxdepth 1 -type d); do \
		PLATFORM_NAME=$$(basename $$PLATFORM); \
		ARCHIVE_NAME=$(NAME)_$(VERSION)_$${PLATFORM_NAME}; \
		\
		if [ $$PLATFORM_NAME = "dist" ]; then \
			continue; \
		fi; \
		\
		pushd $$PLATFORM; \
		zip $(CURDIR)/pkg/dist/$(VERSION)/$${ARCHIVE_NAME}.zip *; \
		popd; \
	done

	pushd pkg/dist/$(VERSION); \
	shasum -a 256 * > $(VERSION)_SHASUMS; \
	popd

.PHONY: cross-build
cross-build: deps-cross-build
	rm -rf pkg/*
	gox -os="darwin linux windows" -arch="386 amd64" -output "pkg/{{.OS}}_{{.Arch}}/{{.Dir}}"

.PHONY: deps-cross-build
deps-cross-build: deps lib/bindata.go gox

.PHONY: gox
gox:
ifeq ($(shell command -v gox 2> /dev/null),)
	go get github.com/mitchellh/gox
endif

# Release binary archives to GitHub
.PHONY: release
release: deps-release
	ghr $(VERSION) pkg/dist/$(VERSION)

.PHONY: deps-release
deps-release: ghr

.PHONY: ghr
ghr:
ifeq ($(shell command -v ghr 2> /dev/null),)
	go get github.com/tcnksm/ghr
endif
