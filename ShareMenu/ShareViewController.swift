//
//  ShareViewController.swift
//  ShareMenu
//
//  Created by 史 翔新 on 2020/01/09.
//  Copyright © 2020 Crazism. All rights reserved.
//

@preconcurrency import UIKit
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

    enum SupportedAttachmentType {
        case url
        case text
    }

    @IBOutlet private weak var qrImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var sharingItemSwitch: UISegmentedControl!
    
    private lazy var generator = QRPictureGenerator()
    private lazy var historyManager = HistoryManager()

    private typealias SharingItem = (type: SupportedAttachmentType, content: String)
    private var sharingItems: [SharingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        Task {
            if let items = await retrieveData() {
                refreshView(with: items)
            }
        }
    }
    
    private func initialize() {
                
        qrImageView.layer.magnificationFilter = .nearest
        
    }
    
    private func retrieveData() async -> [SharingItem]? {
        
        guard let inputItem = extensionContext?.inputItems.first(compacted: { $0 as? NSExtensionItem }) else {
            return nil
        }

        return await parsingSharingItems(from: inputItem)

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

        Task {
            await historyManager.addHistory(selectedItem.content)
        }

    }
    
    @IBAction private func dismiss() {
        extensionContext?.cancelRequest(withError: Dismiss.dummyError)
    }
    
}

extension ShareViewController {

    private func loadItem(from attachment: sending NSItemProvider, as typeIdentifier: String) async -> SharingItem? {

        enum Error: Swift.Error {
            case typeMismatch(parsedType: SupportedAttachmentType, parsedItem: any NSSecureCoding)
        }

        do {
            guard let type = try SupportedAttachmentType(typeIdentifier: typeIdentifier) else {
                return nil
            }
            let item = try await attachment.loadItem(forTypeIdentifier: typeIdentifier)

            switch type {
            case .url:
                guard let url = item as? URL else {
                    throw Error.typeMismatch(parsedType: type, parsedItem: item)
                }
                return (type, url.absoluteString)

            case .text:
                guard let text = item as? String else {
                    throw Error.typeMismatch(parsedType: type, parsedItem: item)
                }
                return (type, text)
            }
            
        } catch {
            assertionFailure("Failed to load item for \(typeIdentifier). Error: \(error)")
            return nil
        }
        
    }

    private func parsingSharingItems(from inputItem: NSExtensionItem) async -> [SharingItem] {

        guard let attachments = inputItem.attachments else {
            return []
        }

        var output: [SharingItem] = []
        for attachment in attachments {
            for identifier in attachment.registeredTypeIdentifiers {
                if let item = await loadItem(from: attachment, as: identifier) {
                    output.append(item)
                }
            }
        }
        
        return output
        
    }
    
    private func updateSharingItemSwitch() {
        
        sharingItemSwitch.removeAllSegments()
        
        sharingItems.enumerated().forEach { (index, item) in
            sharingItemSwitch.insertSegment(withTitle: item.type.title, at: index, animated: false)
        }
        
        assert(sharingItemSwitch.numberOfSegments == sharingItems.count)
        
        sharingItemSwitch.initializeSelectedIndexIfNeeded()
        sharingItemSwitch.showOrHideAccordingToNumberOfSegments()
        
        switchSegment(sender: sharingItemSwitch)
        
    }
    
}

extension ShareViewController.SupportedAttachmentType {
    enum InitError: Error {
        case uknownIdentifier(String)
    }

    init?(typeIdentifier: String) throws {
        guard let utType = UTType(typeIdentifier) else {
            throw InitError.uknownIdentifier(typeIdentifier)
        }
        switch utType {
        case .text, .plainText:
            self = .text

        case .url:
            self = .url

        default:
            return nil
        }
    }

    var utType: UTType {
        switch self {
        case .text:
            return .text

        case .url:
            return .url
        }
    }

    var title: String {
        switch self {
        case .url:
            "URL"

        case .text:
            "Text"
        }
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
