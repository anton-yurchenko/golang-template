I := "⚪"
E := "🔴"
NAME := $(notdir $(CURDIR))
OSES := linux darwin windows
ARCHS := amd64 arm64

test: lint
	@echo "$(I) unit testing..."
	@go test -v $$(go list ./... | grep -v vendor | grep -v mocks) -race -coverprofile=coverage.txt -covermode=atomic

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

.PHONY: init
init:
	@mv .vscode/launch-template.json .vscode/launch.json 2>/dev/null || :
	@rm -rf go.mod go.sum ./vendor
	@go mod init $$(pwd | awk -F'/' '{print $$NF}')

.PHONY: build
release: test
	@echo "$(I) cleaning..."
	@rm -rf ./dist
	@mkdir -p dist
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

.PHONY: codecov
codecov: test
	@go tool cover -html=coverage.txt || (echo "$(E) 'go tool cover' error"; exit 1)

GO_LINTER := $(GOPATH)/bin/golangci-lint
$(GO_LINTER):
	@echo "installing linter..."
	go get -u github.com/golangci/golangci-lint/cmd/golangci-lint
