I := "⚪"
E := "🔴"
NAME := $(notdir $(CURDIR))
OSES := linux darwin windows
ARCHS := amd64 arm64

.PHONY: lint
lint: $(GO_LINTER)
	@echo "$(I) Executing command: go get"
	@GOPRIVATE=github.com/* go get ./... || (echo "$(E) 'go get' error"; exit 1)
	# @echo "$(I) Executing command: mockery"
	# @mockery || (echo "$(E) 'mockery' error"; exit 1)
	@echo "$(I) Executing command: go mod tidy"
	@GOPRIVATE=github.com/* go mod tidy || (echo "$(E) 'go mod tidy' error"; exit 1)
	@echo "$(I) Executing command: go mod vendor"
	@GOPRIVATE=github.com/* go mod vendor || (echo "$(E) 'go mod vendor' error"; exit 1)
	@echo "$(I) Executing command: golangci-lint"
	@golangci-lint run ./... --exclude-dirs 'mocks|vendor|test' || (echo "$(E) golangci-lint error"; exit 1)
	$(MAKE) test

.PHONY: init
init:
	@echo "$(I) Executing command: go mod init"
	@rm -rf go.mod go.sum ./vendor ./mocks
	@go mod init $$(pwd | awk -F'/' '{print "github.com/"$$(NF-1)"/"$$NF}') || (echo "$(E) initialization error"; exit 1)
	$(MAKE) lint

.PHONY: codecov
codecov: test
	@go tool cover -html=coverage.txt || (echo "$(E) 'go tool cover' error"; exit 1)

.PHONY: test
test:
	@echo "$(I) Executing command: go test"
	@go test -v $$(go list ./... | grep -v vendor | grep -v mocks) -race -coverprofile=coverage.txt -covermode=atomic

.PHONY: build
release: test
	@echo "$(I) Executing command: mkdir ./dist"
	@rm -rf ./dist
	@mkdir dist
	@for ARCH in $(ARCHS); do \
		for OS in $(OSES); do \
			@echo "$(I) Executing command: go build $$OS-$$ARCH..."
			if test "$$OS" = "windows"; then \
				GOOS=$$OS GOARCH=$$ARCH go build -o dist/$(NAME)-$$OS-$$ARCH.exe; \
			else \
				GOOS=$$OS GOARCH=$$ARCH go build -o dist/$(NAME)-$$OS-$$ARCH; \
			fi; \
		done; \
	done

GO_LINTER := $(GOPATH)/bin/golangci-lint
$(GO_LINTER):
	@echo "Executing command: go get golangci-lint"
	@go get -u github.com/golangci/golangci-lint/cmd/golangci-lint || (echo "$(E) linter installation error"; exit 1)
