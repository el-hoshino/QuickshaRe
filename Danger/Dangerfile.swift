import Foundation
import Danger
import DangerSwiftKantoku
import DangerSwiftEda
import DangerSwiftCoverage

// MARK: - 便利な拡張
private extension ProcessInfo {
    
    static var xcTestResultPath: String {
        
        // If running on Xcode Cloud it should be able to get path from `$CI_RESULT_BUNDLE_PATH` variable
        processInfo.environment["CI_RESULT_BUNDLE_PATH"] ??
        
        // Else if running locally, remember to pass `Test.xcresult` to `-resultBundlePath` parameter in `xcodebuild` command
        "Test.xcresult"
        
    }
    
}

private extension SwiftLint.SwiftlintPath {
    
    static var installedBySwiftPM: Self {
        let swiftPackagePath = "$(pwd)/SwiftPackages"
        return .swiftPackage(swiftPackagePath)
    }
    
}

// MARK: - チェックルーチン
let danger = Danger()

// Xcode ビルドのワーニング等確認
danger.kantoku.parseXCResultFile(at: ProcessInfo.xcTestResultPath, configuration: .default)

// Xcode test coverage check.
// temporarily disable this because hasn't found a way to get coverage at post_xcodebuild yet
//Coverage.xcodeBuildCoverage(.xcresultBundle(ProcessInfo.xcTestResultPath), minimumCoverage: 60)

// PR ルーチンチェック
danger.eda.checkPR(workflow: .gitFlow(configuration: .default))
