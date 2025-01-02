//
//  HistoryManagerProtocol.swift
//  
//
//  Created by 史 翔新 on 2023/03/24.
//

import Foundation
import Observation

// A history manager protocol
protocol HistoryManagerProtocol: Sendable, Observable {
    func addHistory(_ history: History) async
    func deleteHistory(_ history: History) async
    func deleteAllHistories() async
    func getHistories() async -> [History]
}
