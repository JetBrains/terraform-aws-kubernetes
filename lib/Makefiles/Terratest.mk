SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

is.go.installed:
> @command -v go || ( echo "Golang is not installed" && exit 127 )

tests: is.go.installed
> @cd tests/unit_tests
> @rm -f go.{mod,sum}
> @go mod init "jetbrains/terraform"
> @go mod tidy
> @SKIP_print_plan=true go test -v
> @rm -fr go.{mod,sum}
