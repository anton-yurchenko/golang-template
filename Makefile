I := "⚪"
E := "🔴"
NAME := $(notdir $(CURDIR))
OSES := linux darwin windows
ARCHS := amd64 arm64

.PHONY: lint
lint: $(GO_LINTER)
	@echo "$(I) installing dependencies..."
	@go get ./... || (echo "$(E) 'go get' error"; exit 1)
	@echo "$(I) updating imports..."
	@go mod tidy || (echo "$(E) 'go mod tidy' error"; exit 1)
	@echo "$(I) vendoring..."
	@go mod vendor || (echo "$(E) 'go mod vendor' error"; exit 1)
	@echo "$(I) linting..."
	@golangci-lint run ./... || (echo "$(E) linter error"; exit 1)
	$(MAKE) test

.PHONY: init
init:
	@echo "$(I) initializing..."
	@rm -rf go.mod go.sum ./vendor ./mocks
	@go mod init $$(pwd | awk -F'/' '{print $$NF}')

.PHONY: codecov
codecov: test
	@go tool cover -html=coverage.txt || (echo "$(E) 'go tool cover' error"; exit 1)

.PHONY: test
test:
	@echo "$(I) regenerating mocks package..."
	# @mockery --name=<interface-name>
	# @mockery --name=<interface-name> --dir=vendor/github.com/<org>/<proj>/
	# @mockery --name=<interface-name> 
	@echo "$(I) unit testing..."
	@go test -v $$(go list ./... | grep -v vendor | grep -v mocks) -race -coverprofile=coverage.txt -covermode=atomic

.PHONY: build
release: test
	@echo "$(I) cleaning..."
	@rm -rf ./dist
	@mkdir dist
	@for ARCH in $(ARCHS); do \
		for OS in $(OSES); do \
			@echo "$(I) building for $$OS-$$ARCH..."
			if test "$$OS" = "windows"; then \
				GOOS=$$OS GOARCH=$$ARCH go build -o dist/$(NAME)-$$OS-$$ARCH.exe; \
			else \
				GOOS=$$OS GOARCH=$$ARCH go build -o dist/$(NAME)-$$OS-$$ARCH; \
			fi; \
		done; \
	done

GO_LINTER := $(GOPATH)/bin/golangci-lint
$(GO_LINTER):
	@echo "installing linter..."
	@go get -u github.com/golangci/golangci-lint/cmd/golangci-lint
