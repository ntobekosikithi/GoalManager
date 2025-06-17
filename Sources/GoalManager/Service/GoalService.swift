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
internal final actor GoalServiceImplementation: GoalService {

    // MARK: - Storage Keys

    private enum StorageKey {
        static let weeklyGoals = "Weekly_Goals_Key"
        static let weeklyProgress = "Weekly_Progress_Key"
    }

    // MARK: - Dependencies

    private let dataStorage: DataStorage
    private let logger: Logger

    // MARK: - Init

    init(
        dataStorage: DataStorage = DataStorageImplementation(),
        logger: Logger = LoggerImplementation()
    ) {
        self.dataStorage = dataStorage
        self.logger = logger
    }

    // MARK: - Goal Methods

    func saveGoal(_ goal: Goal) async throws {
        do {
            var goals = try await getAllGoals()
            goals.removeAll { $0.id == goal.id }
            goals.append(goal)

            try dataStorage.save(goals, forKey: StorageKey.weeklyGoals)
            logger.info("Saved goal: \(goal.id)")
        } catch {
            logger.error("Failed to save goal: \(goal.id), error: \(error)")
            throw error
        }
    }

    func getAllGoals() async throws -> [Goal] {
        try dataStorage.retrieve([Goal].self, forKey: StorageKey.weeklyGoals) ?? []
    }

    func getGoal(by id: UUID) async throws -> Goal? {
        do {
            let goals = try await getAllGoals()
            return goals.first { $0.id == id }
        } catch {
            logger.error("Failed to retrieve goal by id: \(id), error: \(error)")
            throw error
        }
    }

    func deleteGoal(_ id: UUID) async throws {
        do {
            var goals = try await getAllGoals()
            goals.removeAll { $0.id == id }

            try dataStorage.save(goals, forKey: StorageKey.weeklyGoals)
            logger.info("Deleted goal: \(id)")
        } catch {
            logger.error("Failed to delete goal: \(id), error: \(error)")
            throw error
        }
    }

    // MARK: - Progress Methods

    func saveProgress(_ progress: GoalProgress) async throws {
        do {
            var progressList = try await getWeeklyProgress()
            progressList.removeAll { $0.id == progress.id }
            progressList.append(progress)

            try dataStorage.save(progressList, forKey: StorageKey.weeklyProgress)
            logger.info("Saved progress for goal: \(progress.goalId)")
        } catch {
            logger.error("Failed to save progress: \(progress.id), error: \(error)")
            throw error
        }
    }

    func getWeeklyProgress() async throws -> [GoalProgress] {
        try dataStorage.retrieve([GoalProgress].self, forKey: StorageKey.weeklyProgress) ?? []
    }
}

