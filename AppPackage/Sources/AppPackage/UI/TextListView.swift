//
//  TextListView.swift
//
//
//  Created by 史 翔新 on 2023/04/16.
//

import SwiftUI

struct TextListView: View {
    
    @Environment(\.histories) var histories: [History]?
    @Environment(\.deleteHistory) var deleteHistory: DeleteHistoryAction?
    
    var body: some View {
        NavigationStack {
            if let histories {
                List {
                    historyList(of: histories)
                }
            } else {
                Text("Loading...")
            }
        }
    }
    
    private func historyList(of histories: [History]) -> some View {
        ForEach(histories, id: \.self) { text in
            NavigationLink(text) {
                QRCodeImageView(
                    content: text
                )
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    Task {
                        await deleteHistory?(of: text)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
}

#if DEBUG
@Observable
private final class PreviewManager: Sendable {
    @MainActor
    var histories: [History] = [
        "Hello",
        "World",
        "This",
        "Is",
        "A",
        "Preview",
        "Of",
        "TextListView",
    ]
    
    init() {}
}
private let manager: PreviewManager = .init()
private func deleteHistoryAction(in manager: PreviewManager) -> DeleteHistoryAction {
    .preview(with: { history in
        Task { @MainActor in
            manager.histories.removeAll(where: { $0 == history })
        }
    })
}
private extension EnvironmentValues {
    var previewManager: PreviewManager { manager }
    @MainActor var previewHistories: [History]? { previewManager.histories }
    var previewAction: DeleteHistoryAction? { deleteHistoryAction(in: previewManager) }
}

#Preview {
    TextListView(
        histories: .init(\.previewHistories),
        deleteHistory: .init(\.previewAction)
    )
}
#endif
