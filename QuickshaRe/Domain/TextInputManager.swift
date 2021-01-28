//
//  TextInputManager.swift
//  QuickshaRe
//
//  Created by 史 翔新 on 2021/01/29.
//  Copyright © 2021 Crazism. All rights reserved.
//

import Foundation

public final class TextInputManager {
    
    private var inputTextHistory: [String] = []
    
}

extension TextInputManager: TextInputManagerObject {
    
    var inputText: String {
        get {
            return inputTextHistory.last ?? "" // swiftlint:disable:this optional_default_value
        }
        set {
            guard !newValue.isEmpty && newValue != inputTextHistory.last else {
                return
            }
            inputTextHistory.append(newValue)
        }
    }
    
}
