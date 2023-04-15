//
//  TextListView.swift
//
//
//  Created by 史 翔新 on 2023/04/16.
//

import SwiftUI

protocol ObservableTextListObject: ObservableObject {
    var textList: [String] { get }
    func remove(_ text: String)
}

private struct NavigationList<Content: View>: View {
    private var content: () -> Content
    init(content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        NavigationStack {
            List {
                content()
            }
        }
    }
}

struct TextListView<ListObject: ObservableTextListObject>: View {
    
    @ObservedObject var listObject: ListObject
    
    var body: some View {
        NavigationList {
            ForEach(listObject.textList, id: \.self) { text in
                NavigationLink(text) {
                    QRCodeImageView(
                        generator: QRPictureGenerator.shared,
                        content: text
                    )
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        listObject.remove(text)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
    
}

struct TextListView_Previews: PreviewProvider {
    private final class PreviewListObject: ObservableTextListObject {
        @Published private(set) var textList: [String] = [
            "Hello",
            "World",
            "This",
            "Is",
            "A",
            "Preview",
            "Of",
            "TextListView",
        ]
        func remove(_ text: String) {
            textList.removeAll { $0 == text }
        }
    }
    static var previews: some View {
        TextListView(listObject: PreviewListObject())
    }
}
