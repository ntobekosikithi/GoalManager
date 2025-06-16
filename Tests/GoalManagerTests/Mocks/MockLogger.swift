//
//  MockLogger.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//


@testable import Utilities
import Foundation

public final class MockLogger: Logger {
    public private(set) var loggedMessages: [String] = []
    public private(set) var infoMessages: [String] = []
    public private(set) var errorMessages: [String] = []
    public private(set) var debugMessages: [String] = []

    public init() {}

    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formatted = format(message, file: file, function: function, line: line)
        infoMessages.append(formatted)
        loggedMessages.append(formatted)
    }

    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formatted = format(message, file: file, function: function, line: line)
        errorMessages.append(formatted)
        loggedMessages.append(formatted)
    }

    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formatted = format(message, file: file, function: function, line: line)
        debugMessages.append(formatted)
        loggedMessages.append(formatted)
    }

    private func format(_ message: String, file: String, function: String, line: Int) -> String {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        return "[\(fileName):\(line)] \(function) - \(message)"
    }
}
