//
//  HistoryManager.swift
//  
//
//  Created by 史 翔新 on 2023/03/24.
//

import Foundation

final class HistoryManager {
    
    private let userDefaults = UserDefaults.standard
    private let defaultsKey = "GenerationHistory"
    private let maxHistoryCount = 50
    
    private var histories: [History] {
        //
        didSet {
            userDefaults.set(histories, forKey: defaultsKey)
        }
    }
    
    init() {
        
        // Load the history list from the user defaults.
        if let array = userDefaults.array(forKey: defaultsKey) {
            
            // If the object in the list is not a history, it is an error.
            guard let histories = array as? [History] else {
                assertionFailure("Invalid history object")
                self.histories = []
                return
            }
            
            self.histories = histories
            
        } else {
            self.histories = []
        }
    }
    
}

extension HistoryManager: HistoryManagerProtocol {
    
    func addHistory(_ history: History) {
        
        // If the history is already in the list, do nothing.
        guard !histories.contains(history) else { return }
        
        histories.append(history)
        
        // If the list is too long, remove the oldest history.
        while histories.count >= maxHistoryCount {
            histories.removeFirst()
        }
    }
    
    func deleteHistory(_ history: History) {
        
        // If the history is not in the list, do nothing.
        while let index = histories.firstIndex(of: history) {
            histories.remove(at: index)
        }
        
    }
    
    func deleteAllHistories() {
        
        histories.removeAll()
        
    }
    
    func getHistories() -> [History] {
        
        // Return the list in the order of the most recent history.
        return histories.reversed()
        
    }
    
    
}
