#!/bin/zsh

source ci_variables.sh

set -ex

if [ $CI_XCODEBUILD_ACTION = "archive" ]; then
    danger_run
fi
