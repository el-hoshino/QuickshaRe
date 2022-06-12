#!/bin/zsh

source ci_variables.sh

cd ${DANGER_PATH}
swift run danger-swift ci --cwd ${PROJECT_PATH}
