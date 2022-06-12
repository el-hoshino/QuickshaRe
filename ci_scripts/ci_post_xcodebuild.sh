#!/bin/zsh

source ci_variables.sh

cd ${DANGER_PATH}
npm install
swift build
swift run danger-swift ci --danger-js-path node_modules/.bin/danger --cwd ${PROJECT_PATH}
