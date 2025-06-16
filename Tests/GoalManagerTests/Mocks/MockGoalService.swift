//
//  MockGoalService.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import Foundation
@testable import Utilities
@testable import GoalManager

class MockGoalService: GoalService, @unchecked Sendable {
    
    
    var shouldThrowError = false
    var goalsToReturn: [Goal] = []
    var progressToReturn: [GoalProgress] = []
    
    var saveGoalCallCount = 0
    var deleteGoalCallCount = 0
    var getAllGoalsCallCount = 0
    var saveProgressCallCount = 0
    var getWeeklyProgressCallCount = 0
    
    var lastSavedGoal: Goal?
    var lastDeletedGoalId: UUID?
    var lastSavedProgress: GoalProgress?
    
    func saveGoal(_ goal: Goal) async throws {
        saveGoalCallCount += 1
        lastSavedGoal = goal
        if shouldThrowError {
            throw MockError.testError
        }
    }
    
    func getGoal(by id: UUID) async throws -> Utilities.Goal? {
        goalsToReturn.first
    }
    
    func deleteGoal(_ goalId: UUID) async throws {
        deleteGoalCallCount += 1
        lastDeletedGoalId = goalId
        if shouldThrowError {
            throw MockError.testError
        }
    }
    
    func getAllGoals() async throws -> [Goal] {
        getAllGoalsCallCount += 1
        if shouldThrowError {
            throw MockError.testError
        }
        return goalsToReturn
    }
    
    func saveProgress(_ progress: GoalProgress) async throws {
        saveProgressCallCount += 1
        lastSavedProgress = progress
        if shouldThrowError {
            throw MockError.testError
        }
    }
    
    func getWeeklyProgress() async throws -> [GoalProgress] {
        getWeeklyProgressCallCount += 1
        if shouldThrowError {
            throw MockError.testError
        }
        return progressToReturn
    }
}

enum MockError: Error {
    case testError
}
