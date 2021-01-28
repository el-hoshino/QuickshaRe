import Foundation
import Danger

for commit in Danger().git.commits {
    message("\(commit)")
    message("==")
}
