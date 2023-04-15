//
//  HistoryManagerProtocol.swift
//  
//
//  Created by 史 翔新 on 2023/03/24.
//

import Foundation

// A history manager protocol
protocol HistoryManagerProtocol {
    func addHistory(_ history: History)
    func deleteHistory(_ history: History)
    func deleteAllHistories()
    func getHistories() -> [History]
}
