//
//  TextInputViewTests.swift
//  QuickshaReTests
//
//  Created by 史 翔新 on 2020/09/12.
//  Copyright © 2020 Crazism. All rights reserved.
//

import XCTest
import ViewInspector
@testable import QuickshaRe

class TextInputViewTests: XCTestCase {
    
    func testTextInputView() throws {
        
        let view = TextInputView()
        
        let inputTextFieldText = try view
            .inputTextField()
            .text()
            .string()
        XCTAssertEqual(inputTextFieldText, "Type here to input text")
        
        let generateButtonText = try view
            .generateButton()
            .label()
            .text()
            .string()
        XCTAssertEqual(generateButtonText, "Generate")
        
    }
    
}

extension TextInputView: Inspectable {
    
    func inputTextField() throws -> InspectableView<ViewType.TextField> {
        
        try inspect()
        .hStack()
        .vStack(0)
        .textField(0)
        
    }
    
    func generateButton() throws -> InspectableView<ViewType.NavigationLink> {
        
        try inspect()
        .hStack()
        .navigationLink(1)
        
    }
    
}
