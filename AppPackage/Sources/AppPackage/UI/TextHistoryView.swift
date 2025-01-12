//
//  TextListView.swift
//
//
//  Created by 史 翔新 on 2023/04/16.
//

import SwiftUI

public struct TextHistoryView: View {
    
    @Environment(\.histories) var histories: [History]?
    @Environment(\.deleteHistory) var deleteHistory: DeleteHistoryAction?
    
    public init() {}
    
    public var body: some View {
        if let histories {
            contents(of: histories)
        } else {
            Text("Loading...")
        }
    }
    
    @ViewBuilder
    private func contents(of histories: [History]) -> some View {
        if histories.isEmpty {
            Text("No history available.")
        } else {
            NavigationSplitView {
                List {
                    historyList(of: histories)
                }
                .navigationBarTitle("History")
                .animation(.default, value: histories)
            } detail: {
                Text("Select a history.")
            }
        }
    }
    
    private func historyList(of histories: [History]) -> some View {
        ForEach(histories, id: \.self) { text in
            NavigationLink(text) {
                QRCodeImageView(
                    content: text,
                    shouldAddContentToHistory: false
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
private extension TextHistoryView {
    init(
        histories: Environment<[History]?>,
        deleteHistory: Environment<DeleteHistoryAction?>
    ) {
        self._histories = histories
        self._deleteHistory = deleteHistory
    }
}

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
    TextHistoryView(
        histories: .init(\.previewHistories),
        deleteHistory: .init(\.previewAction)
    )
}
#endif
