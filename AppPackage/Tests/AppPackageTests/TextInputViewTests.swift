//
//  TextInputViewTests.swift
//  QuickshaReTests
//
//  Created by 史 翔新 on 2020/09/12.
//  Copyright © 2020 Crazism. All rights reserved.
//

import XCTest
import ViewInspector
@testable import AppPackage

@MainActor
class TextInputViewTests: XCTestCase {
    
    func testTextInputView() throws {
        
        let view = TextInputView()
        
        let inputTextFieldText = try view
            .inputTextField()
            .labelView()
            .text()
            .string()
        XCTAssertEqual(inputTextFieldText, "Type here to input text")
        
        let generateButtonText = try view
            .generateButton()
            .labelView()
            .text()
            .string()
        XCTAssertEqual(generateButtonText, "Generate")
        
    }
    
}

extension TextInputView {
    
    func inputTextField() throws -> InspectableView<ViewType.TextField> {
        
        try inspect()
            .find(ViewType.TextField.self)
    }
    
    func generateButton() throws -> InspectableView<ViewType.NavigationLink> {
        
        try inspect()
            .find(navigationLink: "Generate")
    }
    
}
