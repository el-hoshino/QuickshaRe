//
//  TextInputManager.swift
//  QuickshaRe
//
//  Created by 史 翔新 on 2021/01/29.
//  Copyright © 2021 Crazism. All rights reserved.
//

import Foundation
import Combine

public final class TextInputManager {
    
    @Published private var current: String?
    @Published private var history: [String] = []
    
    private var cancellablesSet: Set<AnyCancellable> = []
    
    init() {
        let historySubscription = $current
            .compactMap({ $0 })
            .debounce(for: 1, scheduler: RunLoop.current)
            .removeDuplicates()
            .sink(receiveValue: { [unowned self] newValue in
                self.history.keep(first: 99)
                self.history.append(newValue)
            })
        self.cancellablesSet.insert(historySubscription)
        
        let test = $history.sink { (newValue) in
            print(newValue)
        }
        self.cancellablesSet.insert(test)
    }
    
}

extension TextInputManager: TextInputManagerObject {
    
    var inputText: String {
        get {
            return current ?? "" // swiftlint:disable:this optional_default_value
        }
        set {
            current = newValue
        }
    }
    
}
