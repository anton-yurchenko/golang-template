# global
BINARY := $(notdir $(CURDIR))
GO_BIN_DIR := $(GOPATH)/bin
OSES := linux darwin windows
ARCHS := amd64

# unit tests
test: lint
	@echo "unit testing..."
	@go test $$(go list ./... | grep -v vendor | grep -v mocks) -race -coverprofile=coverage.txt -covermode=atomic

# lint
.PHONY: lint
lint: $(GO_LINTER)
	@echo "vendoring..."
	@go mod vendor
	@go mod tidy
	@echo "linting..."
	@golangci-lint run ./...

# initialize
.PHONY: init
init:
	@mv .vscode/launch-template.json .vscode/launch.json || exit 0
	@rm -f go.mod
	@rm -f go.sum
	@rm -rf ./vendor
	@go mod init $$(pwd | awk -F'/' '{print "github.com/"$$(NF-1)"/"$$NF}')

# linter
GO_LINTER := $(GO_BIN_DIR)/golangci-lint
$(GO_LINTER):
	@echo "installing linter..."
	go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

.PHONY: release
release: test
	@rm -rf ./dist
	@mkdir -p dist
	@for ARCH in $(ARCHS); do \
		for OS in $(OSES); do \
			if test "$$OS" = "windows"; then \
				GOOS=$$OS GOARCH=$$ARCH go build -o dist/$(BINARY)-$$OS-$$ARCH.exe; \
			else \
				GOOS=$$OS GOARCH=$$ARCH go build -o dist/$(BINARY)-$$OS-$$ARCH; \
			fi; \
		done; \
	done

.PHONY: codecov
codecov: test
	@go tool cover -html=coverage.txt
