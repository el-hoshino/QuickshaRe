#!/bin/zsh

danger_run() {
    pushd Danger
    brew install npm
    npm install
    swift build
    swift run danger-swift ci --danger-js-path node_modules/.bin/danger --cwd ${CI_WORKSPACE}
}
