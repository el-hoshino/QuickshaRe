import Foundation
import Danger
import DangerSwiftKantoku
import DangerSwiftCoverage
import DangerSwiftHammer

// swiftlint:disable file_length function_body_length
// swiftlint:disable optional_default_value

// MARK: - Variables those may change according to each project

let changelogPath = "CHANGELOG.md"
let versionSpecifyingFile = "QuickshaRe.xcodeproj/project.pbxproj"
let versionSpecifyingText = "MARKETING_VERSION = "

// MARK: - A structure to introduce checking result

struct CheckResult {
    
    let title: String
    
    private(set) var warningsCount = 0
    private(set) var errorsCount = 0
    
    enum Result {
        
        case good
        case acceptable
        case rejected
        
        var markdownSymbol: String {
            switch self {
            case .good:
                return ":tada:"
                
            case .acceptable:
                return ":thinking:"
                
            case .rejected:
                return ":no_good:"
            }
        }
        
    }
    
    typealias Message = (content: String, result: Result)
    private var messages: [Message] = []
    
    private var todos: [String] = []
    
    init(title: String) {
        self.title = title
    }
    
    mutating func askReviewer(to taskToDo: String) {
        
        todos.append(taskToDo)
        
    }
    
    mutating func check(_ item: String, execution: () -> Result) {
        
        let result = execution()
        messages.append((item, result))
        
        switch result {
        case .good:
            break
            
        case .acceptable:
            warningsCount += 1
            
        case .rejected:
            errorsCount += 1
        }
        
    }
    
    var markdownTitle: String {
        
        "### " + title
        
    }
    
    var markdownMessage: String {
        
        let chartHeader = """
            Checking Item | Result
            | ---| --- |
            
            """
        let chartContent = messages.map {
            "\($0.content) | \($0.result.markdownSymbol)"
        } .joined(separator: "\n")
        
        return chartHeader + chartContent
        
    }
    
    var markdownTodos: String {
        
        let todoContent = todos.map {
            "- [ ] \($0)"
        }
        
        return todoContent.joined(separator: "\n")
        
    }
    
}

// MARK: - DangerDSL computed properties

extension DangerDSL {
    
    private var headBranch: String {
        github.pullRequest.head.ref
    }
    
    private var baseBranch: String {
        github.pullRequest.base.ref
    }
    
    private var additions: Int {
        github.pullRequest.additions ?? 0
    }
    
    private var deletions: Int {
        github.pullRequest.deletions ?? 0
    }
    
    private var diffLinesCount: Int {
        additions + deletions
    }
    
    private func hasModifiedFile(at filepath: String) -> Bool {
        git.modifiedFiles.contains(where: { $0 == filepath })
    }
    
    var githubIssue: String? {
        headBranch.substring(of: #"issue/(\d+)"#, options: .regularExpression)
    }
    
    var hasBootstrapSHFileBeenModified: Bool {
        hasModifiedFile(at: "bootstrap.sh")
    }
    
    var hasBrewfileBeenModified: Bool {
        hasModifiedFile(at: "Brewfile")
    }
    
    var hasChangelogBeenModified: Bool {
        hasModifiedFile(at: changelogPath)
    }
    
    var hasMarketingVersionBeenModified: Bool {
        hammer.diffLines(in: versionSpecifyingFile).additions.contains(where: { $0.contains(versionSpecifyingText) })
    }
    
    var isDevelopPR: Bool {
        // Treat PRs merging into develop branch as a develop PR
        baseBranch == "develop"
    }
    
    var isReleasePR: Bool {
        // Treat PRs merging into main branch as a release PR
        baseBranch == "main"
    }
    
}

// MARK: - DangerDSL PR content check

extension DangerDSL {
    
    enum BranchType {
        
        case main
        case develop
        case feature
        case refactor
        case fix
        case issue
        case version
        case ci
        
        static func parsed(from branchName: String) -> BranchType? {
            switch branchName {
            case "main":
                return .main
                
            case "develop":
                return .develop
                
            case let feature where feature.hasPrefix("feature/"):
                return .feature
                
            case let refactor where refactor.hasPrefix("refactor/"):
                return .refactor
                
            case let fix where fix.hasPrefix("fix/"):
                return .fix
                
            case let issue where issue.hasPrefix("issue/"):
                return .issue
                
            case let version where version.hasPrefix("version/"):
                return .version
                
            case let ci where ci.hasPrefix("ci/"):
                return .ci
                
            case _:
                return nil
            }
            
        }
        
    }
    
    func isHeadBranch(_ branchType: BranchType) -> Bool {
        
        BranchType.parsed(from: headBranch) == branchType
        
    }
    
    func isHeadBranch(anyOf branchTypes: [BranchType]) -> Bool {
        
        branchTypes.contains(where: { isHeadBranch($0) })
        
    }
    
    func isBaseBranch(_ branchType: BranchType) -> Bool {
        
        BranchType.parsed(from: baseBranch) == branchType
        
    }
    
}

// MARK: - DangerDSL modifications content check

extension DangerDSL {
    
    // Auto PR created by CI
    func checkCIAutoPRModification(into result: inout CheckResult) {
        
        result.askReviewer(to: "Check if the automatically-created-by-CI content is correct.")
        warn("This PR is created by CI automatically. Please check if the content is correct.")
        
    }
    
    func checkDevelopmentModification(into result: inout CheckResult) {
        
        // It's encouraged to edit changelog in a develop PR
        let doChangelogModificationCheckTitle = "Changelog Modification Check"
        result.check(doChangelogModificationCheckTitle) {
            if hasChangelogBeenModified {
                return .good
                
            } else {
                warn("This PR doesn't contain any modifications to changelog. Please consider if it's necessary to edit it.")
                return .acceptable
            }
        }
        
    }
    
    func checkReleaseModification(into result: inout CheckResult) {
        
        // It's encouraged to check if there's any issue left before releasing a version
        result.askReviewer(to: "Check open issues")
        warn("This is a release PR. Please check if there's any issue left to be resolved.")
        
        // It's required to change version number.
        let doVersionModificationCheckTitle = "Version Modification Check"
        result.check(doVersionModificationCheckTitle) {
            if hasMarketingVersionBeenModified {
                warn("This is a release PR. Please check if the version has been correctly modified.")
                return .acceptable
                
            } else {
                fail("This is a release PR, but it seems there's no version modification, which is requried.")
                return .rejected
            }
        }
        
        // It's strongly encouraged to edit changelog in a release PR.
        let doChangelogModificationCheckTitle = "Changelog Modification Check"
        result.check(doChangelogModificationCheckTitle) {
            if hasChangelogBeenModified {
                warn("This is a release PR. Please check if the changelog has been correctly modified.")
                return .acceptable
                
            } else {
                fail("This is a release PR, but it seems there's no changelog modification, which is strongly encouraged.")
                return .rejected
            }
        }
        
        if hasChangelogBeenModified {
            result.askReviewer(to: doChangelogModificationCheckTitle)
        }
        
    }
    
}

// MARK: - DangerDSL PR review flow

extension DangerDSL {
    
    func doDevelopPRCheck() -> CheckResult {
        
        var result = CheckResult(title: "Develop PR Check")
        
        // Develop PR should be created from a branch which begins with either `feature/`、`refactor/` 、`fix/`、`issue/`, `version/` or `ci/`.
        let doHeadBranchCheckTitle = "PR Head Branch Check"
        let validBranches: [BranchType] = [
            .feature,
            .refactor,
            .fix,
            .issue,
            .version,
            .ci,
        ]
        result.check(doHeadBranchCheckTitle) {
            if isHeadBranch(anyOf: validBranches) {
                return .good
                
            } else {
                fail("Please create a develop PR from either a feature, refactor, fix, issue or version branch.")
                return .rejected
            }
        }
        
        // Develop PR should be created into develop branch
        let doBaseBranchCheckTitle = "PR Base Branch Check"
        result.check(doBaseBranchCheckTitle) {
            if isBaseBranch(.develop) {
                return .good
                
            } else {
                fail("Please create a develop PR into develop branch.")
                return .rejected
            }
        }
        
        // Develop PR shouldn't contain any merge commits.
        let doNoMergeCommitsCheckTitle = "Merge Commits Excluded Check"
        result.check(doNoMergeCommitsCheckTitle) {
            if github.commits.allSatisfy({ $0.commit.parents == nil }) {
                return .good
                
            } else {
                fail("Develop PR should not contain any merge commits. Please consider rebasing if needed.")
                return .rejected
                
            }
        }
        
        // The volume of diff should not be over 1,000 lines.
        let doDiffAmountCheckTitle = "Diff Volume Check"
        result.check(doDiffAmountCheckTitle) {
            if diffLinesCount <= 1_000 {
                return .good
                
            } else {
                warn("There's too much diff. Please consider splitting this PR.")
                return .acceptable
            }
        }
        
        if isHeadBranch(.ci) {
            // If the PR is created from the branch created by CI, do the CI auto PR modification check.
            checkCIAutoPRModification(into: &result)
            
        } else if isHeadBranch(.version) {
            // If the PR is created from a version branch, do the release modification check.
            checkReleaseModification(into: &result)
            
        } else {
            // Otherwise, do the develop modification check.
            checkDevelopmentModification(into: &result)
        }
        
        return result
        
    }
    
    func doReleasePRCheck() -> CheckResult {
        
        var result = CheckResult(title: "Release PR Check")
        
        // Release PR should be created from develop branch.
        let doHeadBranchCheckTitle = "PR Head Branch Check"
        result.check(doHeadBranchCheckTitle) {
            if isHeadBranch(.develop) {
                return .good
                
            } else {
                fail("Please create a release PR from develop branch.")
                return .rejected
            }
        }

        // Develop PR should be created into main branch
        let doBaseBranchCheckTitle = "PR Base Branch Check"
        result.check(doBaseBranchCheckTitle) {
            if isBaseBranch(.main) {
                return .good
                
            } else {
                fail("Please create a release PR into main branch.")
                return .rejected
            }
        }
        
        // Do the release modification check.
        checkReleaseModification(into: &result)
        
        return result
        
    }
    
    enum RoutineError: Error {
        case failedToFindCheckRoutine
    }
    
    func checkPR() throws -> CheckResult {
        
        if isDevelopPR {
            return doDevelopPRCheck()
            
        } else if isReleasePR {
            return doReleasePRCheck()
            
        } else {
            throw RoutineError.failedToFindCheckRoutine
        }
        
    }
    
}

// MARK: - Other convenient extensions

private extension Git {
    
    var diffFiles: [File] {
        createdFiles + deletedFiles + modifiedFiles
    }
    
}

private extension String {
    
    func substring <S: StringProtocol> (of string: S, options: CompareOptions) -> String? {
        
        guard let range = range(of: string, options: options) else {
            return nil
        }
        
        return String(self[range])
        
    }
    
}

private extension ProcessInfo {
    
    static var xcTestResultPath: String {
        
        // If running on Xcode Cloud it should be able to get path from `$CI_RESULT_BUNDLE_PATH` variable
        processInfo.environment["CI_RESULT_BUNDLE_PATH"] ??
        
        // If running on Bitrise it should be able to get path from `$BITRISE_XCRESULT_PATH` variable
        processInfo.environment["BITRISE_XCRESULT_PATH"] ??
            
        // Else if running locally, remember to pass `Test.xcresult` to `-resultBundlePath` parameter in `xcodebuild` command
        "Test.xcresult"
        
    }
    
}

// MARK: - Check routine
let danger = Danger()

// If there's any modification in bootstrap.sh file, ask the reviewer to check if he needs to update Bitrise workflows.
if danger.hasBrewfileBeenModified {
    markdown("- [ ] Check bitrise workflow")
    warn("There's modification in bootstrap.sh file. Please remember to check if needed to update Bitrise workflow.")
}

// If the head branch refers to a GitHub issue, comment it in the PR page.
if let githubIssue = danger.githubIssue {
    message("Resolve #\(githubIssue)")
}

// SwiftLint format check.
SwiftLint.lint(.modifiedAndCreatedFiles(directory: nil), inline: true, configFile: "swiftlint.yml")

// Xcode summary warnings check.
danger.kantoku.parseXCResultFile(at: ProcessInfo.xcTestResultPath, configuration: .default)

// Xcode test coverage check.
Coverage.xcodeBuildCoverage(.xcresultBundle(ProcessInfo.xcTestResultPath), minimumCoverage: 60)

// PR routine check.
do {
    let result = try danger.checkPR()
    markdown(result.markdownTitle)
    
    if !result.markdownMessage.isEmpty {
        markdown(result.markdownMessage)
    }
    
    if !result.markdownTodos.isEmpty {
        markdown(result.markdownTodos)
    }
    
    if result.warningsCount == 0 && result.errorsCount == 0 {
        message("Well Done :white_flower:")
    }
    
} catch {
    fail("Failed to find out the correct check routine. Please check if your PR is created from or into a correct branch.")
}
