//
//  QRCodeGeneratorObject.swift
//  QuickshaRe
//
//  Created by 史 翔新 on 2021/01/28.
//  Copyright © 2021 Crazism. All rights reserved.
//

import Foundation

public protocol QRCodeGeneratorObject: AnyObject {
    func qrPicture(for text: String) -> Picture
}

import SwiftUI

public extension EnvironmentValues {
    @Entry var qrCodeGenerator: QRCodeGeneratorObject?
}
