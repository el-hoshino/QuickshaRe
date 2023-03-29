#!/bin/zsh

set_skip_swift_package_plugin_validation() {
    defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
}
