MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MAKEFILE_DIR)/makefile_scripts

.PHONY: bootstrap
.PHONY: update
.PHONY: xcodegen

default: bootstrap

bootstrap:
	$(SCRIPTS_DIR)/bootstrap.sh

update:
	$(SCRIPTS_DIR)/bootstrap.sh --update

xcodegen:
	$(SCRIPTS_DIR)/bootstrap.sh --xcodegen_only
