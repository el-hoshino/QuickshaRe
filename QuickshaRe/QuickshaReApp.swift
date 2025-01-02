//
//  QuickshaReApp.swift
//  QuickshaRe
//
//  Created by 史 翔新 on 2021/01/11.
//

import SwiftUI
import AppPackage

@main
struct QuickshaReApp: App {
    @State private var qrCodeGenerator: QRCodeGeneratorObject = QRPictureGenerator()
    @State private var historyManager: HistoryManagerProtocol = HistoryManager()
    var body: some Scene {
        WindowGroup {
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
        }
        .environment(\.qrCodeGenerator, qrCodeGenerator)
        .environment(\.historyManager, historyManager)
    }
}
