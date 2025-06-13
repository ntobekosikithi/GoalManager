//
//  Goal.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/13.
//

import Foundation
import Utilities

public struct Goal: Codable, Identifiable, Equatable {
    public let id: UUID
    public let type: GoalType
    public let targetValue: Double
    public let period: GoalPeriod
    public let createdAt: Date
    public var currentValue: Double
    
    public init(type: GoalType, targetValue: Double, period: GoalPeriod) {
        self.id = UUID()
        self.type = type
        self.targetValue = targetValue
        self.period = period
        self.createdAt = Date()
        self.currentValue = 0
    }
    
    public var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue * 100, 100)
    }
    
    public var isCompleted: Bool {
        currentValue >= targetValue
    }
    
    public var remainingValue: Double {
        max(targetValue - currentValue, 0)
    }
}

public enum GoalType: String, CaseIterable, Codable {
    case workoutCount = "Workout Count"
    case totalDuration = "Total Duration"
    case specificWorkout = "Specific Workout"
    case weeklyActive = "Weekly Active Days"
    
    public var unit: String {
        switch self {
        case .workoutCount, .specificWorkout, .weeklyActive:
            return "workouts"
        case .totalDuration:
            return "minutes"
        }
    }
    
    public var icon: String {
        switch self {
        case .workoutCount:
            return "number.circle"
        case .totalDuration:
            return "clock"
        case .specificWorkout:
            return "figure.run"
        case .weeklyActive:
            return "calendar.badge.checkmark"
        }
    }
}

public enum GoalPeriod: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    public var startDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .daily:
            return calendar.startOfDay(for: now)
        case .weekly:
            return now.startOfWeek
        case .monthly:
            let components = calendar.dateComponents([.year, .month], from: now)
            return calendar.date(from: components) ?? now
        }
    }
    
    public var endDate: Date {
        let calendar = Calendar.current
        
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: startDate) ?? Date()
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: startDate) ?? Date()
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: startDate) ?? Date()
        }
    }
}
