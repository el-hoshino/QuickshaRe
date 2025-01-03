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
        TabView {

            TextInputView()
                .tabItem {
                    Text("New")
                }

            TextHistoryView()
                .tabItem {
                    Text("History")
                }

        }
        .environment(\.qrCodeGenerator, qrCodeGenerator)
        .environment(\.historyManager, historyManager)
    }

}

#Preview {
    AppRootView()
}
