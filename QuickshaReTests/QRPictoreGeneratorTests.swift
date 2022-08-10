//
//  QRPictoreGeneratorTests.swift
//  QRPictoreGeneratorTests
//
//  Created by 史翔新 on 2019/12/17.
//  Copyright © 2019 Crazism. All rights reserved.
//

import XCTest
import CoreImage
@testable import QuickshaRe

class QRPictoreGeneratorTests: XCTestCase {
    
    func testPictureGeneration() {
        
        let message = "abc"
        let generator = QRPictureGenerator()
        let picture = generator.qrPicture(for: message)
        
        let attachment = XCTAttachment(image: picture.uiImage)
        add(attachment)
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil)!
        let features = detector.features(in: CIImage(image: picture.uiImage)!) as! [CIQRCodeFeature] // swiftlint:disable:this force_cast
//        XCTAssertEqual(features[0].messageString, message)
        XCTAssertFalse(features.isEmpty)
    }
    
}
