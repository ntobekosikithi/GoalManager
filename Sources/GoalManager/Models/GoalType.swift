//
//  GoalType.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation

public enum GoalType: String, CaseIterable, Codable, Sendable {
    case workoutCount = "Workout Count"
    case totalDuration = "Total Duration"
    case distance = "Distance"
    case calories = "Calories"
    case steps = "Steps"
    
    public var systemImage: String {
        switch self {
        case .workoutCount: return "number.circle"
        case .totalDuration: return "clock"
        case .distance: return "location"
        case .calories: return "flame"
        case .steps: return "footprints"
        }
    }
    
    public var defaultUnit: String {
        switch self {
        case .workoutCount: return "workouts"
        case .totalDuration: return "minutes"
        case .distance: return "km"
        case .calories: return "kcal"
        case .steps: return "steps"
        }
    }
}
