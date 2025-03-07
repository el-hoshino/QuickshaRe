//
//  HistoryManager.swift
//
//
//  Created by 史 翔新 on 2023/03/24.
//

import Foundation
import Observation

private let defaultSuiteName = "group.net.crazism.QuickshaRe"

@Observable
public final class HistoryManager: Sendable {
    
    private enum SaveDataVersion: Codable {
        // swiftlint:disable:next identifier_name
        case v1
    }
    
    @MainActor
    private let userDefaults: UserDefaults = .init(suiteName: defaultSuiteName) ?? { // swiftlint:disable:this optional_default_value
        assertionFailure("Failed to initialize UserDefaults with suite name \(defaultSuiteName)")
        return .standard
    }()
    private let defaultsVersionKey = "HistoryManagerDefaultsVersion"
    private let defaultsHistoryKey = "HistoryManagerGenerationHistory"
    private let maxHistoryCount = 50

    @MainActor
    private var initializationFinished: Bool = false

    @MainActor
    private var histories: [History]? {
        didSet {
            assert(canSetHistories(against: oldValue))
            saveHistoriesIfAvailable()
        }
    }

    @MainActor
    private func canSetHistories(against oldValue: [History]?) -> Bool {
        if oldValue == nil {
            return !initializationFinished
        } else {
            return true
        }
    }

    @MainActor
    public init() {
        
        // Load the history list from the user defaults.
        guard let historyDataVersion: SaveDataVersion = userDefaults.loadCodable(forKey: defaultsVersionKey) else {
            defer { initializationFinished = true }
            self.histories = []
            return
        }
        
        Task {
            defer { initializationFinished = true }
            await migrateSaveDataVersionIfNeeded(from: historyDataVersion)
            await loadHistoriesFromUserDefaults()
        }
    }
    
    private func migrateSaveDataVersionIfNeeded(from existVersion: SaveDataVersion) async {
        // Currently only v1, so does nothing.
        assert(existVersion == .v1)
    }
    
    private func loadHistoriesFromUserDefaults() async {
        await MainActor.run {
            // swiftlint:disable:next optional_default_value
            let array: [History]? = userDefaults.loadCodable(forKey: defaultsHistoryKey) ?? []
            self.histories = array
        }
    }
    
    @MainActor
    private func saveHistoriesIfAvailable() {
        guard let histories else { return }
        userDefaults.saveCodable(SaveDataVersion.v1, forKey: defaultsVersionKey)
        userDefaults.saveCodable(histories, forKey: defaultsHistoryKey)
        userDefaults.synchronize()
    }

    @discardableResult
    @MainActor
    private func waitForHistories() async -> [History] {
        while true {
            if let histories {
                return histories
            }
            await Task.yield()
        }
    }

}

extension HistoryManager: HistoryManagerProtocol {

    public func reloadHistories() async {
        await loadHistoriesFromUserDefaults()
    }

    public func addHistory(_ history: History) async {

        await waitForHistories()

        // If history already exist, remove it before adding it so it'll be listed at last.
        await MainActor.run {
            if let existHistoryIndex = histories?.firstIndex(of: history) {
                histories?.remove(at: existHistoryIndex)
            }
        }

        // Make sure there's no the same history before adding it.
        await MainActor.run {
            if let histories {
                assert(!histories.contains(history))
            }
            histories?.append(history)
        }
        
        // If the list is too long, remove the oldest history.
        await MainActor.run { [self] in
            // swiftlint:disable:next optional_default_value
            while (histories?.count ?? 0) >= maxHistoryCount {
                self.histories?.removeFirst()
            }
        }
    }
    
    public func deleteHistory(_ history: History) async {
        
        await waitForHistories()

        // If the history is not in the list, do nothing.
        await MainActor.run { [self] in
            while let index = histories?.firstIndex(of: history) {
                self.histories?.remove(at: index)
            }
        }
        
    }
    
    public func deleteAllHistories() async {
        
        await waitForHistories()

        await MainActor.run {
            histories?.removeAll()
        }
        
    }
    
    @MainActor
    public func getHistories() -> [History] {
        
        // Return the list in the order of the most recent history.
        guard let histories else {
            return []
        }
        return histories.reversed()
        
    }
    
}

private extension UserDefaults {
    func saveCodable<Element: Codable>(_ value: Element, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        setValue(data, forKey: key)
    }
    
    func loadCodable<Element: Codable>(forKey key: String) -> Element? {
        guard let data = data(forKey: key) else { return nil }
        let element = try? JSONDecoder().decode(Element.self, from: data)
        return element
    }
}
