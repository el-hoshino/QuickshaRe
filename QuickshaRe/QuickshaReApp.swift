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
    var body: some Scene {
        WindowGroup {
            NavigationView(content: {
                TextInputView()
                Text("Input text from navigation bar to generate QR code image 😘")
            })
        }
        .environment(\.qrCodeGenerator, qrCodeGenerator)
    }
}
