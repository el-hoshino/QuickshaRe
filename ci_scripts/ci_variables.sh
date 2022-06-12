#!/bin/zsh

## Local variables
PROJECT_PATH=${CI_WORKSPACE:-${BITRISE_SOURCE_DIR:-../}}
SWIFT_PACKAGES_PATH=${PROJECT_PATH}/SwiftPackages
DANGER_PATH=${PROJECT_PATH}/Danger

## Local functions
_swift_exec="xcrun -sdk macosx swift"
_swift_package_path="--package-path ${SWIFT_PACKAGES_PATH}"
swift_package_build() {
    eval $_swift_exec build $_swift_package_path
}

swift_package_run() {
    eval $_swift_exec run $_swift_package_path $@
}
