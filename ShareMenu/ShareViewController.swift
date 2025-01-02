//
//  ShareViewController.swift
//  ShareMenu
//
//  Created by 史 翔新 on 2020/01/09.
//  Copyright © 2020 Crazism. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import AppPackage
import UniformTypeIdentifiers

@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {
    
    /// On dismiss, cancelRequest requires an error but in practice it is NOT. So just give it a dummy error
    struct Dismiss: Error {
        static let dummyError: Dismiss = .init()
    }
    
    @IBOutlet private weak var qrImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var sharingItemSwitch: UISegmentedControl!
    
    private lazy var generator = QRPictureGenerator()
    
    private typealias SharingItem = (type: String, content: String)
    private var sharingItems: [SharingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        retrieveData { [weak self] (items) in
            DispatchQueue.main.async {
                self?.refreshView(with: items)
            }
        }
    }
    
    private func initialize() {
                
        qrImageView.layer.magnificationFilter = .nearest
        
    }
    
    private func retrieveData(completion: @escaping ([SharingItem]) -> Void) {
        
        guard let inputItem = extensionContext?.inputItems.first(compacted: { $0 as? NSExtensionItem }) else {
            return
        }
        
        DispatchQueue.global().async {
            let parsed = self.parsingSharingItems(from: inputItem)
            completion(parsed)
        }
        
    }
    
    private func refreshView(with items: [SharingItem]) {
        
        sharingItems = items
        
        updateSharingItemSwitch()
        
    }
    
    @IBAction private func switchSegment(sender: UISegmentedControl) {
        
        guard sharingItems.indices.contains(sender.selectedSegmentIndex) else {
            assertionFailure("Invalid index \(sender.selectedSegmentIndex)")
            return
        }
        
        let selectedItem = sharingItems[sender.selectedSegmentIndex]
        textLabel.text = selectedItem.content
        let image = generator.qrPicture(for: selectedItem.content)
        qrImageView.image = image.uiImage
        
    }
    
    @IBAction private func dismiss() {
        extensionContext?.cancelRequest(withError: Dismiss.dummyError)
    }
    
}

extension ShareViewController {
    
    // TODO: Migrate to Swift Concurrency
    private func loadItem(from attachment: NSItemProvider, as typeIdentifier: String, completion: @escaping (SharingItem?) -> Void) {
        
        attachment.loadItem(forTypeIdentifier: typeIdentifier) { (coding, error) in
            
            guard let item = coding else {
                assertionFailure("Failed to load item for \(typeIdentifier). Error: \(error as Any)")
                return completion(nil)
            }
            
            guard let type = UTType(typeIdentifier) else {
                defer { completion(nil) }
                return
            }

            switch type {
            case .url:
                guard let url = item as? URL else { assertionFailure("Failed to load item as URL."); break }
                return completion(("URL", url.absoluteString))
                
            case .text, .plainText:
                guard let text = item as? String else { assertionFailure("Failed to load item as Text."); break }
                return completion(("Text", text))
                
            default:
                return completion(nil)
            }
            
        }
        
    }
    
    private func parsingSharingItems(from inputItem: NSExtensionItem) -> [SharingItem] {
        
        var output: [SharingItem] = []
        
        let dispatchGroup = DispatchGroup()
        
        for attatchment in inputItem.attachments ?? [] { // swiftlint:disable:this optional_default_value
            for identifier in attatchment.registeredTypeIdentifiers {
                
                dispatchGroup.enter()
                loadItem(from: attatchment, as: identifier, completion: { [dispatchGroup] item in
                    defer { dispatchGroup.leave() }
                    
                    if let item = item {
                        output.append(item)
                    }
                    
                })
                
            }
            
        }
        
        dispatchGroup.wait()
        
        return output
        
    }
    
    private func updateSharingItemSwitch() {
        
        sharingItemSwitch.removeAllSegments()
        
        sharingItems.enumerated().forEach { (index, item) in
            sharingItemSwitch.insertSegment(withTitle: item.type, at: index, animated: false)
        }
        
        assert(sharingItemSwitch.numberOfSegments == sharingItems.count)
        
        sharingItemSwitch.initializeSelectedIndexIfNeeded()
        sharingItemSwitch.showOrHideAccordingToNumberOfSegments()
        
        switchSegment(sender: sharingItemSwitch)
        
    }
    
}

extension Sequence {
    
    func first <Output> (compacted transform: (Element) throws -> Output?) rethrows -> Output? {
        var iterator = makeIterator()
        while let next = iterator.next() {
            if let output = try transform(next) {
                return output
            }
        }
        return nil
    }
    
}

private extension UISegmentedControl {
    
    func initializeSelectedIndexIfNeeded() {
        
        if numberOfSegments > 0, selectedSegmentIndex < 0 {
            selectedSegmentIndex = 0
        }
        
    }
    
    func showOrHideAccordingToNumberOfSegments() {
        
        if numberOfSegments <= 1 {
            isHidden = true
            
        } else {
            isHidden = false
        }
        
    }
    
}
