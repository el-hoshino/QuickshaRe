//
//  QuickshaReUITests.swift
//  QuickshaReUITests
//
//  Created by 史翔新 on 2019/12/17.
//  Copyright © 2019 Crazism. All rights reserved.
//

import XCTest
import CoreImage

class QuickshaReUITests: XCTestCase {
    
    func testQRCodeGenerationFromMainApp() {
        
        let app = XCUIApplication()
        app.launch()
        
        let inputTextField = app.textFields["Type here to input text"]
        let generateButton = app.buttons["Generate"]
        
        XCTContext.runActivity(named: "Check initial screen") { activity -> Void in
            
            XCTAssert(inputTextField.exists)
            XCTAssert(generateButton.exists)
            
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            activity.add(attachment)
            
        }
        
        let testMessage = "Share any text via QR Code!"
        
        XCTContext.runActivity(named: "Check text input") { _ -> Void in
            
            inputTextField.tap()
            inputTextField.typeText(testMessage)
            generateButton.tap()
            
        }
        
        let label = app.staticTexts[testMessage]
        
        XCTContext.runActivity(named: "Check QR Code output") { activity -> Void in
            
            XCTAssert(label.waitForExistence(timeout: 2))
            
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            activity.add(attachment)
            
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil)!
            let features = detector.features(in: CIImage(image: screenshot.image)!) as! [CIQRCodeFeature]
            XCTAssertEqual(features[0].messageString, testMessage)
            
        }
        
    }
    
}
