//
//  ContentView.swift
//  QuickshaRe
//
//  Created by 史翔新 on 2019/12/17.
//  Copyright © 2019 Crazism. All rights reserved.
//

import SwiftUI
import Combine

struct QRCodeImageView: View {
    
    @Environment(\.qrCodeGenerator) var generator: QRCodeGeneratorObject?
    
    var content: String
    
    init(content: String) {
        self.content = content
    }
    
    var body: some View {
        VStack {
            qrCodeImage
            Text(content)
            Spacer()
        }
    }
    
    @ViewBuilder
    private var qrCodeImage: some View {
        if let generator {
            Image(uiImage: generator.qrPicture(for: content).uiImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()

        } else {
            Text("Failed to initialize QRCode Generator")
        }
    }
}

#if DEBUG
@MainActor
private let qrCodeGenerator = QRPictureGenerator()
#Preview {
    NavigationStack {
        QRCodeImageView(
            content: "https://github.com/el-hoshino/QuickshaRe"
        )
    }
    .environment(\.qrCodeGenerator, qrCodeGenerator)
}
#endif
