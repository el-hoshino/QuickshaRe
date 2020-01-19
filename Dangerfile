# Variables according to this project

## .xcodeproj file path
def xcodeproj_path
    
    return "QuickshaRe.xcodeproj"
    
end

## .xcworkspace file path
def xcworkspace_path
    
    return "QuickshaRe.xcworkspace"
    
end

## Scheme name to test
def scheme_to_test
    
    return "QuickshaRe"
    
end

## Info.plist file path
def info_plist_path
    
    return "QuickshaRe/Info.plist"
    
end

## CHANGELOG path
def changelog_path
    
    return "CHANGELOG.md"
    
end

# End variables according to this project

# PR check result declaration
class CheckResult

    attr_accessor :warnings, :errors, :title, :message

    def initialize(title)
        @warnings = 0
        @errors = 0
        @title = "## " + title
        @message = markdown_message_template
    end

    def markdown_message_template
        template = "Checklist | Result\n"
        template << "|--- | --- |\n"
        return template
    end

end

# Find GitHub Issue
def find_github_issue
    
    issue = github.branch_for_head.match("issue/(\\d+)")
    if issue
        return issue
    end
    
end

# Modification check on bootstrap.sh file
def bootstrap_sh_has_been_modified
    
    modified = !git.modified_files.grep("bootstrap.sh").empty?
    return modified
    
end

# Modification check on Info.plist file
def info_plist_has_been_modified
    
    modified = git.modified_files.include?(info_plist_path)
    return modified
    
end

# Modification check on CHANGELOG.md file
def changelog_has_been_modified
    
    modified = git.modified_files.include?(changelog_path)
    return modified
    
end

# Modification check for Marketing Version variable
def marketing_version_has_been_modified
    
    project_setting_file_path = xcodeproj_path + "/project.pbxproj"
    project_setting_file_diff = git.diff_for_file(project_setting_file_path)
    if project_setting_file_diff
        project_setting_file_diff.patch.lines.each do |line|
            if line.include?("MARKETING_VERSION = ")
                return true
            end
        end
    end
    
end

# Check xcode_summary result
def common_xcode_summary_check
    
    xcode_summary.inline_mode = true
    xcode_summary.report 'xcodebuild.json'
    
end

# Check xcode_coverage result
def common_xcode_coverage_check
    
    slather.configure(xcodeproj_path, scheme_to_test, options: {
      workspace: xcworkspace_path,
      ci_service: :bitrise,
    })
    
    slather.notify_if_coverage_is_less_than(minimum_coverage: 50)
    slather.notify_if_modified_file_is_less_than(minimum_coverage: 0) # SwiftUI files are currently not very convenient to write a unit testing.
    slather.show_coverage
    
end

# Check SwiftLint result
def common_swiftlint_check
    
    swiftlint.config_file = '.swiftlint.yml'
    swiftlint.lint_files inline_mode: true
    
end

def is_develop_pr

    ## Any PR whose base branch is `develop` is a develop PR
    is_to_develop = github.branch_for_base == "develop"
    if is_to_develop
        return true
    else
        return false
    end

end

def is_release_pr

    ## Any PR whose base branch is `master` is a release PR
    is_to_master = github.branch_for_base == "master"
    if is_to_master
        return true
    else
        return false
    end

end

# Check development modifications
def development_modification_check_into_result(result)
    
    ## Recommanded to update CHANGELOG.md
    result.message << "CHANGELOG.md Modification Check |"
    has_changelog_modification = changelog_has_been_modified
    
    if has_changelog_modification
        result.message << ":o:\n"
    else
        warn "This PR doesn't contain any modification to CHANGELOG.md file, which is recommanded."
        result.message << ":heavy_exclamation_mark:\n"
        result.warnings += 1
    end
    
    return result
    
end

# Check release modifications
def release_modification_check_into_result(result)
    
    ## Ask reviewer to make sure if all issues those should be resolved in this version are done.
    result.message << "Check Remaining Issues |"
    result.message += ":heavy_exclamation_mark:\n"
    warn "This is a release PR. Please check if all issues those should be resolved in this version are done."
    
    ## Required to update Info.plist.
    result.message << "Info.plist Modification Check |"
    has_info_plist_modification = info_plist_has_been_modified
    has_marketing_version_modification = marketing_version_has_been_modified
    
    if has_info_plist_modification || has_marketing_version_modification
        result.message += ":heavy_exclamation_mark:\n"
        warn "This is a release PR. Please check if app version is correctly updated."
    else
        fail "This is a release PR but app version isn't updated, which is required."
        result.message += ":x:\n"
        result.errors += 1
    end

    ## Required to update CHANGELOG.md
    result.message << "CHANGELOG.md Modification Check |"
    has_changelog_modification = changelog_has_been_modified
    
    if has_changelog_modification
        result.message += ":heavy_exclamation_mark:\n"
        warn "This is a release PR. Please check if CHANGELOG.md is correctly updated."
    else
        fail "This is a release PR but CHANGELOG.md isn't updated, which is required."
        result.message += ":x:\n"
        result.errors += 1
    end
    
    return result
    
end

# Develop PR review routine
def develop_pr_check

    result = CheckResult.new("Develop PR Check")

    ## A develop PR should be pushed from a branch whose name starts with `feature/`、`refactor/` 、`fix/`、`issue/` or `version/`.
    result.message << "Check PR From branch |"
    is_from_feature = github.branch_for_head.start_with?("feature/")
    is_from_refactor = github.branch_for_head.start_with?("refactor/")
    is_from_fix = github.branch_for_head.start_with?("fix/")
    is_from_issue = github.branch_for_head.start_with?("issue/")
    is_from_version = github.branch_for_head.start_with?("version/")
    if is_from_feature || is_from_refactor || is_from_fix || is_from_issue || is_from_version
        result.message << ":o:\n"
    else
        fail "Please apply a develop PR from a branch whose name starts with `feature/`、`refactor/` 、`fix/`、`issue/` or `version/`."
        result.message << ":x:\n"
        result.errors += 1
    end

    ## A develop PR should be merged to the branch `develop`.
    result.message << "Check PR To branch |"
    is_to_develop = github.branch_for_base == "develop"
    if is_to_develop
        result.message << ":o:\n"
    else
        fail "Please apply a develop PR to the branch `develop`."
        result.message << ":x:\n"
        result.errors += 1
    end

    if is_from_version
        ## If the PR is pushed from a version branch, do a release modification check.
        release_modification_check_into_result(result)
    else
        ## Else, do a development modification check.
        development_modification_check_into_result(result)
    end
    
    ## There should be no merge commits in a develop PR.
    result.message << "Merge Commit Check |"
    contains_merge_commits = git.commits.any? { |c| c.parents.length > 1 }
    unless contains_merge_commits
        result.message << ":o:\n"
    else
        fail "A develop PR should NOT contain any merge commits. If needed please consider a rebase before applying a PR."
        result.message << ":x:\n"
        result.errors += 1
    end

    ## The volume of the modification should be less than 1,000 lines.
    result.message << "Volume of Modification Check |"
    is_fix_too_big = git.lines_of_code > 1_000
    unless is_fix_too_big
        result.message << ":o:\n"
    else
        warn "There's too much modifications. Please consider splitting this PR."
        result.message << ":heavy_exclamation_mark:\n"
        result.warnings += 1
    end

    return result

end

# Release PR review routine
def release_pr_check

    result = CheckResult.new("Release PR Check")

    ## A release PR should be pushed from the branch `develop`.
    result.message << "Check PR From branch |"
    is_from_develop = github.branch_for_head == "develop"
    if is_from_develop
        result.message += ":o:\n"
    else
        fail "Please apply a release PR from the branch `develop`."
        result.message += ":x:\n"
        result.errors += 1
    end

    ## A release PR should be merged to the branch `master`.
    result.message << "Check PR To branch |"
    is_to_master = github.branch_for_base == "master"
    if is_to_master
        result.message += ":o:\n"
    else
        fail "Please apply a release PR to the branch `master`"
        result.message += ":x:\n"
        result.errors += 1
    end

    # Do a release modification check.
    release_modification_check_into_result(result)

    return result

end

# Main routine

## If there's any modification in bootstrap.sh file, ask the reviewer to check Bitrise workflow updates.
if bootstrap_sh_has_been_modified
    warn "This PR contains modifications to bootstrap.sh file, which means maybe an update to Bitrise workflow is needed."
end

## If there's an issue number in the name of the pushed branch, add a comment of that issue to the PR.
github_issue = find_github_issue
if github_issue
    message "Resolve ##{github_issue[1]}"
end

## Check SwiftLint warnings.
common_swiftlint_check

## Check Xcode Summary warnings.
common_xcode_summary_check

## Check Xcode test coverage.
common_xcode_coverage_check

## Set the check routines.
if is_develop_pr
    check_result = develop_pr_check
elsif is_release_pr
    check_result = release_pr_check
end

if check_result
    markdown(check_result.title)
    markdown(check_result.message)

    if check_result.errors == 0 && check_result.warnings == 0
        message "Perfect :white_flower:"
    end

else
    fail "Failed to specify the check routine. Please make sure your PR is applied to `develop` or `master` branch."
end
