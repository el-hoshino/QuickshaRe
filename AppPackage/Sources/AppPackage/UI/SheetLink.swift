//
//  SheetLink.swift
//  AppPackage
//
//  Created by 史翔新 on 2025/01/12.
//

import SwiftUI

struct SheetLink<L: View, C: View>: View {

    @State private var isPresented: Bool = false

    var content: () -> C
    var label: () -> L

    var body: some View {
        Button {
            isPresented = true
        } label: {
            label()
        }
        .sheet(isPresented: $isPresented, content: content)
    }

}
