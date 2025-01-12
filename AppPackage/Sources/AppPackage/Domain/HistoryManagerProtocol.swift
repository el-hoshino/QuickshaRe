//
//  HistoryManagerProtocol.swift
//
//
//  Created by 史 翔新 on 2023/03/24.
//

import Foundation
import Observation

// A history manager protocol
public protocol HistoryManagerProtocol: Sendable, Observable {
    func reloadHistories() async
    func addHistory(_ history: History) async
    func deleteHistory(_ history: History) async
    func deleteAllHistories() async
    @MainActor
    func getHistories() -> [History]
}

public struct AddHistoryAction: Sendable {
    private var execution: @Sendable (_ history: History) async -> Void
    fileprivate init(execution: @Sendable @escaping (History) async -> Void) {
        self.execution = execution
    }
    public static func preview(with execution: @Sendable @escaping (History) async -> Void = { _ in }) -> Self {
        return self.init(execution: {
            print(#file, #line, #function)
            await execution($0)
        })
    }
    public func callAsFunction(_ history: History) async {
        await execution(history)
    }
}

public struct DeleteHistoryAction: Sendable {
    private var execution: @Sendable (_ history: History) async -> Void
    fileprivate init(execution: @Sendable @escaping (History) async -> Void) {
        self.execution = execution
    }
    public static func preview(with execution: @Sendable @escaping (History) async -> Void = { _ in }) -> Self {
        return self.init(execution: {
            print(#file, #line, #function)
            await execution($0)
        })
    }
    public func callAsFunction(of history: History) async {
        await execution(history)
    }
}

public struct DeleteAllHistoriesAction: Sendable {
    private var execution: @Sendable () async -> Void
    fileprivate init(execution: @Sendable @escaping () async -> Void) {
        self.execution = execution
    }
    public static func preview(with execution: @Sendable @escaping () async -> Void = {}) -> Self {
        return self.init(execution: {
            print(#file, #line, #function)
            await execution()
        })
    }
    public func callAsFunction() async {
        await execution()
    }
}

private extension HistoryManagerProtocol {
    var addHistoryAction: AddHistoryAction {
        .init(execution: { history in
            await addHistory(history)
        })
    }
    var deleteHistoryAction: DeleteHistoryAction {
        .init(execution: { history in
            await deleteHistory(history)
        })
    }
    var deleteAllHistoriesAction: DeleteAllHistoriesAction {
        .init(execution: {
            await deleteAllHistories()
        })
    }
}

import SwiftUI

public extension EnvironmentValues {
    @Entry var historyManager: HistoryManagerProtocol?
    @MainActor var histories: [History]? {
        historyManager?.getHistories()
    }
    var addHistory: AddHistoryAction? {
        historyManager?.addHistoryAction
    }
    var deleteHistory: DeleteHistoryAction? {
        historyManager?.deleteHistoryAction
    }
    var deleteAllHistories: DeleteAllHistoriesAction? {
        historyManager?.deleteAllHistoriesAction
    }
}
