//
//  QRPictureGenerator.swift
//  QuickshaRe
//
//  Created by 史翔新 on 2020/01/08.
//  Copyright © 2020 Crazism. All rights reserved.
//

import CoreImage.CIFilterBuiltins

public final class QRPictureGenerator {
    
    let context = CIContext()
    
}

extension QRPictureGenerator: QRCodeGeneratorObject {
    
    public func qrPicture(for text: String) -> Picture {
        
        let ciGenerator = CIFilter.qrCodeGenerator()
        let qrCode = ciGenerator.qrCodeImage(for: text, correctionLevel: "H")!
        let output = context.createCGImage(qrCode, from: qrCode.extent)!
        
        return .init(cgImage: output)
        
    }
    
}

private extension CIQRCodeGenerator where Self: CIFilter {
    
    func qrCodeImage(for text: String, correctionLevel: String) -> CIImage? {
        
        self.correctionLevel = correctionLevel
        self.message = text.data(using: .utf8)!
        
        return outputImage
        
    }
    
}
