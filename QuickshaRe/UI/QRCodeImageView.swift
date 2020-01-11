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
    
    private let generator = QRPictureGenerator()
    
    @State var content: String
    
    var body: some View {
        VStack {
            Image(uiImage: generator.qrPicture(for: content).uiImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
            Text(content)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            NavigationView {
                QRCodeImageView(content: "https://github.com/el-hoshino/QuickshaRe")
            }.environment(\.colorScheme, .light)
            
            NavigationView {
                QRCodeImageView(content: "https://github.com/el-hoshino/QuickshaRe")
            }.environment(\.colorScheme, .dark)
            
        }
        
    }
    
}
