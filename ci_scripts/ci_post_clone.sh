#!/bin/zsh

source ci_variables.sh

set -ex

swift_package_build

if [ $CI_XCODEBUILD_ACTION = "build-for-testing" ]; then
    danger_install
fi
