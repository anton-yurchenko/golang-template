# golang-starter-kit

## Overview

- `make`:
  - vendor
  - tidy
  - make lint
  - make test

- `make init`: re-initialize project as go module
- `make lint`: run linter on all packages except for vendor directory.
- `make test`: run tests with code coverage profiling on all packages except for vendor directory.
- `make codecov`: run `make` and open code coverage report.
- `make build`: create release directory with compiled binaries.
  - run `make`.
  - builds for linux/amd64, darwin/amd64, windows/amd64.

## Manual

1. Rewrite README.md
2. Remove not required directories and all *.gitkeep* files
3. Initialize Go Module with `make init`
