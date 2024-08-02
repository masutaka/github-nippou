NAME := github-nippou
SRCS := go.mod go.sum $(shell find . -type f ! -path ./statik/statik.go -name '*.go' ! -name '*_test.go')
CONFIGS := $(wildcard config/*)
VERSION := v$(shell grep 'const Version ' lib/version.go | sed -E 's/.*"(.+)"$$/\1/')
PACKAGES := $(shell go list ./...)

ifeq (Windows_NT, $(OS))
NAME := $(NAME).exe
endif

all: $(NAME)

# Install dependencies for development
.PHONY: deps
deps: statik
	go mod download

.PHONY: statik
statik:
ifeq ($(shell command -v statik 2> /dev/null),)
	go install github.com/rakyll/statik@latest
endif

# Build binary
$(NAME): statik/statik.go $(SRCS)
	go build -o $(NAME)

statik/statik.go: $(CONFIGS)
	go generate

# Install binary to $GOPATH/bin
.PHONY: install
install:
	go install

# Clean binary
.PHONY: clean
clean:
	$(RM) $(NAME)

# Test for development
.PHONY: test
test: statik/statik.go
	go test -v $(PACKAGES)

# Test for CI
.PHONY: test-all
test-all: deps-test-all vet lint test

.PHONY: deps-test-all
deps-test-all: statik golint statik/statik.go
	go mod download

.PHONY: golint
golint:
ifeq ($(shell command -v golint 2> /dev/null),)
	go install golang.org/x/lint/golint@latest
endif

.PHONY: vet
vet:
	go vet $(PACKAGES)

.PHONY: lint
lint:
	echo $(PACKAGES) | xargs -n1 golint -set_exit_status

# Bump go version
.PHONY: bump_go_version
bump_go_version:
	@printf "go version (x.y.z)? "; read version; \
	go mod edit -go="$$version"
	go mod tidy

# Generate binary archives for release check on local machine
.PHONY: dist
dist: deps-dist
	goreleaser release --snapshot --clean

.PHONY: deps-dist
deps-dist: goreleaser

# Release binary archives to GitHub
.PHONY: release
release: deps-release release-check
	goreleaser --clean

.PHONY: deps-release
deps-release: goreleaser

.PHONY: release-check
release-check:
	goreleaser check

.PHONY: goreleaser
goreleaser:
ifeq ($(shell command -v goreleaser 2> /dev/null),)
	go install github.com/goreleaser/goreleaser@latest
endif
