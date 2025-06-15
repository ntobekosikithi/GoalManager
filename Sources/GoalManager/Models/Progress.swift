//
//  Progress.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//


import Foundation

public struct Progress: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let goalId: UUID
    public let value: Double
    public let date: Date
    public let notes: String?
    
    public init(
        id: UUID = UUID(),
        goalId: UUID,
        value: Double,
        date: Date,
        notes: String? = nil
    ) {
        self.id = id
        self.goalId = goalId
        self.value = value
        self.date = date
        self.notes = notes
    }
}
