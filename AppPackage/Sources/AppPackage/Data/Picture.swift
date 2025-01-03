//
//  Picture.swift
//  QuickshaRe
//
//  Created by 史翔新 on 2020/01/08.
//  Copyright © 2020 Crazism. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import CoreGraphics

public struct Picture: Sendable {
    
    fileprivate enum ImageType: Sendable {
        case uiImage(UIImage)
        case cgImage(CGImage)
    }
    
    private var imageData: ImageType
    
    init(uiImage: UIImage) {
        self.imageData = .uiImage(uiImage)
    }
    
    init(cgImage: CGImage) {
        self.imageData = .cgImage(cgImage)
    }
    
    public var uiImage: UIImage {
        return imageData.uiImage
    }
    
}

private extension Picture.ImageType {
    
    var uiImage: UIImage {
        switch self {
        case .uiImage(let image):
            return image
            
        case .cgImage(let image):
            return UIImage(cgImage: image)
        }
        
    }
    
}
