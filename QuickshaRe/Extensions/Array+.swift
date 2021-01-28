//
//  Array+.swift
//  QuickshaRe
//
//  Created by 史 翔新 on 2021/01/29.
//  Copyright © 2021 Crazism. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func keep(first itemsCount: Int) {
        guard count > itemsCount else {
            return
        }
        self = Array(self[..<itemsCount])
    }
    
}
