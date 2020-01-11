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

public struct Picture {
    
    fileprivate enum ImageType {
        case uiImage(UIImage)
        case ciImage(CIImage)
        case cgImage(CGImage)
    }
    
    private var imageData: ImageType
    
    init(uiImage: UIImage) {
        self.imageData = .uiImage(uiImage)
    }
    
    init(ciImage: CIImage) {
        self.imageData = .ciImage(ciImage)
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
            
        case .ciImage(let image):
            return UIImage(ciImage: image)
            
        case .cgImage(let image):
            return UIImage(cgImage: image)
        }
        
    }
    
}
