//
//  Goal.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/13.
//

import Foundation
import Utilities

public struct Goal: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String
    public let type: GoalType
    public let targetValue: Double
    public let unit: String
    public let targetDate: Date
    public let createdAt: Date
    public var isActive: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        type: GoalType,
        targetValue: Double,
        unit: String,
        targetDate: Date,
        createdAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.targetValue = targetValue
        self.unit = unit
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.isActive = isActive
    }
}
