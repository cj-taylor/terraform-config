SHELLCHECK_URL := https://s3.amazonaws.com/travis-blue-public/binaries/ubuntu/14.04/x86_64/shellcheck-0.4.4.tar.bz2
SHFMT_URL := https://github.com/mvdan/sh/releases/download/v2.5.0/shfmt_v2.5.0_linux_amd64
TFPLAN2JSON_URL := github.com/travis-ci/tfplan2json
TFPLAN2JSON_V11_URL := gopkg.in/travis-ci/tfplan2json.v11
PROVIDER_TRAVIS_URL := github.com/travis-ci/terraform-provider-travis

DEPS := \
	.ensure-provider-travis \
	.ensure-rubocop \
	.ensure-shellcheck \
	.ensure-shfmt \
	.ensure-terraforms \
	.ensure-tfplan2json

GOPATH_BIN := $(shell go env GOPATH | awk -F: '{ print $$1 }')/bin

SHELL := bash

GIT := git
GO := go
CURL := curl

.PHONY: test
test:
	./runtests --env .example.env

include $(shell git rev-parse --show-toplevel)/terraform-common.mk

.PHONY: assert-clean
assert-clean:
	$(GIT) diff --exit-code
	$(GIT) diff --cached --exit-code

.PHONY: deps
deps: $(DEPS)

.PHONY: .ensure-terraforms
.ensure-terraforms:
	$(GIT) ls-files '*/Makefile' | \
		xargs -n 1 $(MAKE) .echo-tf-version -f 2>/dev/null | \
		grep -v make | \
		sort | \
		uniq | while read -r tf_version; do \
			./bin/ensure-terraform $${tf_version}; \
		done

.PHONY: .ensure-rubocop
.ensure-rubocop:
	bundle version &>/dev/null || gem install bundler
	bundle exec rubocop --version &>/dev/null || bundle install

.PHONY: .ensure-shellcheck
.ensure-shellcheck:
	if [[ ! -x "$(HOME)/bin/shellcheck" ]]; then \
		$(CURL) -sSL "$(SHELLCHECK_URL)" | tar -C "$(HOME)/bin" -xjf -; \
	fi

.PHONY: .ensure-shfmt
.ensure-shfmt: $(GOPATH_BIN)/shfmt

$(GOPATH_BIN)/shfmt:
	$(CURL) -sSL -o $@ $(SHFMT_URL)
	chmod +x $@

.PHONY: .ensure-tfplan2json
.ensure-tfplan2json:
	$(SHELL) -c 'eval $$(gimme 1.11.1) && $(GO) get -u "$(TFPLAN2JSON_URL)"'
	$(SHELL) -c 'eval $$(gimme 1.9.7) && $(GO) get -u "$(TFPLAN2JSON_V11_URL)"'

.PHONY: .ensure-provider-travis
.ensure-provider-travis:
	$(GO) get -u "$(PROVIDER_TRAVIS_URL)"
	mkdir -p $(HOME)/.terraform.d/plugins
	cp -v $(GOPATH_BIN)/terraform-provider-travis $(HOME)/.terraform.d/plugins/
