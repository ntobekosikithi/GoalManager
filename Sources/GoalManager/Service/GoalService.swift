//
//  GoalService.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation
import Utilities

@available(iOS 13.0, *)
public protocol GoalService: Sendable {
    func saveGoal(_ goal: Goal) async throws
    func getAllGoals() async throws -> [Goal]
    func getGoal(by id: UUID) async throws -> Goal?
    func deleteGoal(_ id: UUID) async throws
    func saveProgress(_ progress: GoalProgress) async throws
    func getWeeklyProgress() async throws -> [GoalProgress]
}

@available(iOS 13.0, *)
final actor GoalServiceImplementation: GoalService {

    private let dataStorage: DataStorage
    private let logger: Logger

    private enum StorageKey {
        static let weeklyGoals = "Weekly_Goals_Key"
        static let weeklyProgress = "Weekly_Progress_Key"
    }

    init(
        dataStorage: DataStorage = DataStorageImplementation(),
        logger: Logger = Logger.shared
    ) {
        self.dataStorage = dataStorage
        self.logger = logger
    }

    func saveGoal(_ goal: Goal) async throws {
        do {
            var allGoals = try await getAllGoals()
            allGoals.removeAll { $0.id == goal.id }
            allGoals.append(goal)
            try dataStorage.save(allGoals, forKey: StorageKey.weeklyGoals)
            logger.info("Saved goal: \(goal.id)")
        } catch {
            logger.error("Failed to save goal: \(goal.id), error: \(error)")
            throw error
        }
    }

    func getAllGoals() async throws -> [Goal] {
        return try dataStorage.retrieve([Goal].self, forKey: StorageKey.weeklyGoals) ?? []
    }

    func getGoal(by id: UUID) async throws -> Goal? {
        do {
            let allGoals = try await getAllGoals()
            return allGoals.first { $0.id == id }
        } catch {
            logger.error("Failed to get goal by id: \(id), error: \(error)")
            throw error
        }
    }

    func deleteGoal(_ id: UUID) async throws {
        do {
            var allGoals = try await getAllGoals()
            allGoals.removeAll { $0.id == id }
            try dataStorage.save(allGoals, forKey: StorageKey.weeklyGoals)
            logger.info("Deleted goal: \(id)")
        } catch {
            logger.error("Failed to delete goal: \(id), error: \(error)")
            throw error
        }
    }

    func saveProgress(_ progress: GoalProgress) async throws {
        do {
            var allProgress = try await getWeeklyProgress()
            allProgress.removeAll { $0.id == progress.id }
            allProgress.append(progress)
            try dataStorage.save(allProgress, forKey: StorageKey.weeklyProgress)
            logger.info("Saved progress for goal: \(progress.goalId)")
        } catch {
            logger.error("Failed to save progress: \(progress.id), error: \(error)")
            throw error
        }
    }

    func getWeeklyProgress() async throws -> [GoalProgress] {
        return try dataStorage.retrieve([GoalProgress].self, forKey: StorageKey.weeklyProgress) ?? []
    }
}
