#!/bin/zsh

source ci_variables.sh

set -ex

cd ${DANGER_PATH}
brew install npm
npm install
swift build
swift run danger-swift ci --danger-js-path node_modules/.bin/danger --cwd ${PROJECT_PATH}
