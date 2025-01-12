//
//  AppRootView.swift
//  AppPackage
//
//  Created by 史翔新 on 2025/01/04.
//

import SwiftUI

public struct AppRootView: View {
    
    @State private var qrCodeGenerator: QRCodeGeneratorObject = QRPictureGenerator()
    @State private var historyManager: HistoryManagerProtocol = HistoryManager()

    public init() {}

    public var body: some View {
        TextInputView()
            .toolbar {
                toolbarContent
            }
            .environment(\.qrCodeGenerator, qrCodeGenerator)
            .environment(\.historyManager, historyManager)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()

            SheetLink {
                TextHistoryView()
            } label: {
                Label("History", systemImage: "archivebox")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderless)
        }

    }

}

#Preview {
    AppRootView()
}
