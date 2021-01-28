//
//  QuickshaReApp.swift
//  QuickshaRe
//
//  Created by 史 翔新 on 2021/01/11.
//

import SwiftUI

@main
struct QuickshaReApp: App {
    
    @StateObject private var inputManager = TextInputManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView(content: {
                TextInputView(inputManager: inputManager)
                Text("Input text from navigation bar to generate QR code image 😘")
            })
        }
    }
    
}
