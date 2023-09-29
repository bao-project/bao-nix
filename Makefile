# SPDX-License-Identifier: Apache-2.0
# Copyright (c) Bao Project and Contributors. All rights reserved.

SHELL:=bash

root_dir:=$(realpath .)
src_dir:=$(root_dir)/pkgs

# Instantiate CI rules
include ci/ci.mk

nix_srcs+=$(shell find $(src_dir) -type f -name '*.nix')

all_files:=$(nix_srcs)
$(call ci, license, "Apache-2.0", $(all_files))

ci: license-check
.PHONY: ci
