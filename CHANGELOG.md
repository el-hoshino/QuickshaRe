# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-01-13

### Added

- History feature!

### Enhanced

- Xcode 16 Support
- iOS 17 & 18 Support
- Swift 6 migration
- Swift Concurrency migration
- Observation migration

### Removed

- iOS 14 ~ 16 support

## [1.0.3] - 2023-02-02

### Enhanced

- Using Danger-Swift instead of ruby Danger.
- Xcode 14 Support
- iOS 16 Support
- Xcode Cloud migration
- Using Swift Package for developing

### Removed

- iOS 13 Support

## [1.0.2] - 2020-06-26

### Added

- Catalyst support.
- Placeholder navigation view for regular horizontal size-classes device, like a landscape iPad.

### Changed

- Close button in share menu is now changed to xmark.circle.fill symbol with a more monochrome tint color.
- Segment switch in share menu is now changed to hidden state initially.

### Enhanced

- Dismissing QR view directly from dismiss button on share extension won't dismiss original iOS share menu now.

## [1.0.1] - 2020-01-19

### Added

- Very basic support for VoiceOver on Share Extension.

### Changed

- View layout on iPad is now changed to double column style.

### Fixed

- Text binding failure between the input view and the output view. This may be crucial on iPad.

### Enhanced

- A better CI/CD environment with SwiftLint and Danger

## [1.0.0] - 2020-01-12

- Initial release.
