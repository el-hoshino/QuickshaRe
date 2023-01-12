#!/bin/zsh

source ci_variables.sh

set -ex

if [ $CI_XCODEBUILD_ACTION = "build-for-testing" ]; then
    danger_run
fi
