//
//  GoalService.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation
import Utilities

@available(iOS 13.0.0, *)
public protocol GoalService: Sendable {
    func saveGoal(_ goal: Goal) async throws
    func getAllGoals() async throws -> [Goal]
    func getGoal(by id: UUID) async throws -> Goal?
    func deleteGoal(_ id: UUID) async throws
    func saveProgress(_ progress: Progress) async throws
    func getWeeklyProgress() async throws -> [Progress]
}

@available(iOS 13.0.0, *)
final actor GoalServiceImplementation: GoalService {
    private var goals: [Goal] = []
    private let dataStorage: DataStorage
    private let logger: Logger
    private let weeklyGoalsKey = "Weekly_Goals_Key"
    
    init(
        dataStorage: DataStorage = DataStorageImplementation(),
        logger: Logger = Logger.shared
    ) {
        self.dataStorage = dataStorage
        self.logger = logger
    }

    func saveGoal(_ goal: Goal) async throws {
        do {
            var goals =  try await getAllGoals()
            if await isSaved(goal) {
                goals.removeAll { $0.id == goal.id }
                goals.append(goal)
            }else{
                goals.append(goal)
            }
            try dataStorage.save(goals, forKey: weeklyGoalsKey)
        } catch {
            logger.error("Failed to load goals: \(error)")
        }
    }
    
    func getAllGoals() async throws -> [Goal] {
        guard let data = try dataStorage.retrieve([Goal].self, forKey: weeklyGoalsKey) else {
            return []
        }
        
        return data
    }
    
    func getGoal(by id: UUID) async throws -> Goal? {
        do {
            let goals =  try await getAllGoals()
            return goals.first { $0.id == id}
        } catch {
            return nil
        }
    }

    func deleteGoal(_ id: UUID) async throws {
        do {
            var goals =  try await getAllGoals()
            goals.removeAll { $0.id == id }
            try dataStorage.save(goals, forKey: weeklyGoalsKey)
            logger.info("Deleted goal: \(id)")
        } catch {
            logger.info("Failed deleting goal: \(id)")
        }
    }
    
    func saveProgress(_ progress: Progress) async throws {
        try dataStorage.save([progress], forKey: weeklyGoalsKey)
        logger.info("Saved progress: \(progress.id)")
    }
    
    func getWeeklyProgress() async throws -> [Progress] {
        guard let data = try dataStorage.retrieve([Progress].self, forKey: weeklyGoalsKey) else {
            return []
        }
        
        return data
    }
    
    func isSaved(_ goal: Goal) async -> Bool {
        do {
            let goals =  try await getAllGoals()
            return goals.contains { $0.id == goal.id }
        } catch {
            return false
        }
    }
}
