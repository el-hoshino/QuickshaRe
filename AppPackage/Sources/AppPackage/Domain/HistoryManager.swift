//
//  HistoryManager.swift
//
//
//  Created by 史 翔新 on 2023/03/24.
//

import Foundation
import Observation

@Observable
public final class HistoryManager: Sendable {
    
    private enum SaveDataVersion: Codable {
        case v1
    }
    
    @MainActor
    private let userDefaults = UserDefaults.standard
    private let defaultsVersionKey = "HistoryManagerDefaultsVersion"
    private let defaultsHistoryKey = "HistoryManagerGenerationHistory"
    private let maxHistoryCount = 50
    
    @MainActor
    private var histories: [History]? {
        didSet {
            saveHistoriesIfAvailable()
        }
    }
    
    @MainActor
    init() {
        
        // Load the history list from the user defaults.
        guard let historyDataVersion = userDefaults.value(forKey: defaultsVersionKey) as? SaveDataVersion else {
            self.histories = []
            return
        }
        
        Task {
            await migrateSaveDataVersionIfNeeded(from: historyDataVersion)
            await initialLoadHistories()
        }
    }
    
    private func migrateSaveDataVersionIfNeeded(from existVersion: SaveDataVersion) async {
        // Currently only v1, so does nothing.
        assert(existVersion == .v1)
    }
    
    private func initialLoadHistories() async {
        let histories = await MainActor.run { () -> [History] in
            let value = userDefaults.array(forKey: defaultsHistoryKey)
            guard let array = value as? [History] else {
                assertionFailure("Invalid history object")
                return []
            }
            return array
        }
        
        await MainActor.run {
            self.histories = histories
        }
        
    }
    
    @MainActor
    private func saveHistoriesIfAvailable() {
        guard let histories else { return }
        userDefaults.set(SaveDataVersion.v1, forKey: defaultsVersionKey)
        userDefaults.set(histories, forKey: defaultsHistoryKey)
    }
    
}

extension HistoryManager: HistoryManagerProtocol {
    
    public func addHistory(_ history: History) async {
        
        await histories.waitForValue()
        
        // If the history is already in the list, do nothing.
        guard await !histories.waitForValue().contains(history) else { return }
        
        await MainActor.run {
            histories?.append(history)
        }
        
        // If the list is too long, remove the oldest history.
        await MainActor.run { [self] in
            while (histories?.count ?? 0) >= maxHistoryCount {
                self.histories?.removeFirst()
            }
        }
    }
    
    public func deleteHistory(_ history: History) async {
        
        await histories.waitForValue()
        
        // If the history is not in the list, do nothing.
        await MainActor.run { [self] in
            while let index = histories?.firstIndex(of: history) {
                self.histories?.remove(at: index)
            }
        }
        
    }
    
    public func deleteAllHistories() async {
        
        await histories.waitForValue()
        
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

private extension Optional {
    @discardableResult
    func waitForValue() async -> Wrapped {
        while true {
            if let self {
                return self
            }
            await Task.yield()
        }
    }
}
