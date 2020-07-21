import Danger
let danger = Danger()

let pr = danger.github.pullRequest
let changedLinesCount = (pr.additions ?? 0) + (pr.deletions ?? 0)
if changedLinesCount > 300 {
    danger.warn("変更量が300行を超えています。PRを分割してください")
}
