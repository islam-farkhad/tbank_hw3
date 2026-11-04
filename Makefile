GO ?= go

.PHONY: tools generate generate-check test check

tools:
	mkdir -p .bin
	GOBIN="$(CURDIR)/.bin" $(GO) install google.golang.org/protobuf/cmd/protoc-gen-go@v1.34.2
	GOBIN="$(CURDIR)/.bin" $(GO) install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1

generate:
	sh scripts/generate.sh

generate-check:
	sh scripts/generate.sh --check

check: generate-check
	$(GO) build ./...
	$(GO) vet ./...
