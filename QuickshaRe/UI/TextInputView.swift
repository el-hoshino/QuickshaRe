//
//  TextInputView.swift
//  QuickshaRe
//
//  Created by 史 翔新 on 2020/01/09.
//  Copyright © 2020 Crazism. All rights reserved.
//

import SwiftUI
import Combine

struct TextInputView: View {
    
    @State var inputText: String = ""
    
    var body: some View {
        HStack {
            TextField("Type here to input text",
                      text: $inputText,
                      onCommit: { [self] in self.endEditing(from: self) })
                .underline()
            NavigationLink(destination: QRCodeImageView(content: $inputText),
                           label: { Text("Generate") })
                .padding(5)
                .border(color: .secondary, cornerRadius: 10, lineWidth: 1)
                .disabled(inputText.isEmpty)
        }
        .padding(6)
        .offset(y: -100)
    }
    
    private func endEditing(from source: Any?) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: source, for: nil)
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

struct TextInputView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            NavigationView {
                TextInputView()
            }.environment(\.colorScheme, .light)
            
            NavigationView {
                TextInputView()
            }.environment(\.colorScheme, .dark)
            
        }
        
    }
    
}
