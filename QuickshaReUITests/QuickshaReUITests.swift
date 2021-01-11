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
            let features = detector.features(in: CIImage(image: screenshot.image)!) as! [CIQRCodeFeature] // swiftlint:disable:this force_cast
            XCTAssertEqual(features[0].messageString, testMessage)
            
        }
        
    }
    
    #if !TEST_ON_CI
    func testQRCodeGenerationFromSafari() {
        
        let app = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        app.launch()
        
        XCTContext.runActivity(named: "Go to about:blank page") { _ -> Void in
            let urlBar = app.otherElements["TopBrowserBar"]
            urlBar.tap()
            let urlField = urlBar.textFields["URL"]
            urlField.typeText("about:blank")
            app.buttons["Go"].tap()
        }
        
        XCTContext.runActivity(named: "Call Share menu") { _ -> Void in
            let shareButton = app.buttons["Share"]
            shareButton.tap()
        }
        
        XCTContext.runActivity(named: "Open QuickshaRe") { _ -> Void in
            // For some reason it seems impossible to properly specify the correct QuickshaRe button by text, so I can only specify it by index and pray that it can work on CI
            // Ref: https://gist.github.com/AvdLee/719b2de80d74fc503ca1c64a23706d93#gistcomment-3142859
            let shareList = app.otherElements["ActivityListView"]
            XCTAssert(shareList.waitForExistence(timeout: 2))
            let button = shareList.cells.matching(identifier: "QuickshaRe").element
            button.tap()
        }
        
        XCTContext.runActivity(named: "Check label and image display") { _ -> Void in
            let view = app.otherElements["Share View"]
            let label = view.staticTexts["about:blank"]
            let image = view.images["QR Image"]
            XCTAssert(view.waitForExistence(timeout: 2))
            XCTAssert(label.exists)
            XCTAssert(image.exists)
        }
        
    }
    #endif
    
}
