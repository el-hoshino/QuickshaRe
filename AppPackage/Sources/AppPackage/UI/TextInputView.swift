//
//  TextInputView.swift
//  QuickshaRe
//
//  Created by 史 翔新 on 2020/01/09.
//  Copyright © 2020 Crazism. All rights reserved.
//

import SwiftUI

public struct TextInputView: View {
    
    @State private var inputText: String = ""
    @State private var displayingQRCodeOfText: String?

    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            inputField
        } detail: {
            Text("Input text from navigation bar to generate QR code image 😘")
        }
    }
    
    private var inputField: some View {
        HStack {
            TextField(
                "Type here to input text",
                text: $inputText,
                onCommit: { [self] in self.endEditing(from: self) }
            )
                .underline()

            Button {
                displayingQRCodeOfText = inputText
            } label: {
                Text("Generate")
                    .padding(5)
                    .border(color: .secondary, cornerRadius: 10, lineWidth: 1)
            }
                .disabled(inputText.isEmpty)
        }
        .padding(6)
        .offset(y: -100)
        .navigationBarTitle("Input")
        .navigationDestination(item: $displayingQRCodeOfText) { text in
            makeQRCodeImageView(for: text)
        }
    }
    
    private func endEditing(from source: Any?) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: source, for: nil)
    }

    private func makeQRCodeImageView(for text: String) -> some View {
        QRCodeImageView(content: text)

    }
    
}

extension View {
    
    func underline() -> some View {
        return VStack {
            self
            Divider()
        }
    }
    
    func border(color: Color, cornerRadius: CGFloat, lineWidth: CGFloat) -> some View {
        
        return overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(color, lineWidth: lineWidth)
        )
        
    }
    
}

#if DEBUG
@MainActor
private let qrCodeGenerator = QRPictureGenerator()
#Preview {
    NavigationView {
        TextInputView()
    }
    .environment(\.qrCodeGenerator, qrCodeGenerator)
}
#endif
