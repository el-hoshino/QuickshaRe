import Foundation
import Danger

for commit in Danger().github.commits {
    message("\(commit)")
    message("==")
}
