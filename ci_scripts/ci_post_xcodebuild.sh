#!/bin/zsh

source ci_variables.sh

set -ex

if [ $CI_XCODEBUILD_ACTION = "test-without-building" ]; then
    danger_install
    danger_run
fi
