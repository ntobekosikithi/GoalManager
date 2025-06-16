// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Utilities

@available(iOS 13.0, *)
@MainActor
public final class GoalManager: ObservableObject {
    @Published public private(set) var currentGoals: [Goal] = []
    @Published public private(set) var weeklyProgress: [GoalProgress] = []

    private let goalService: GoalService
    private let logger: Logger

    public init(
        goalService: GoalService? = nil,
        logger: Logger = Logger.shared
    ) {
        self.goalService = goalService ?? GoalServiceImplementation()
        self.logger = logger
    }

    public func setGoal(_ goal: Goal) async throws {
        logger.info("Setting goal: \(goal.title)")

        do {
            try await goalService.saveGoal(goal)
            await loadGoals()
        } catch {
            logger.error("Failed to set goal: \(error)")
            throw error
        }
    }

    public func updateProgress(for goalId: UUID, value: Double? = 0.0) async throws {
        logger.info("Updating progress for goal: \(goalId)")

        let progress = GoalProgress(
            id: UUID(),
            goalId: goalId,
            value: value ?? 0.0,
            date: Date()
        )

        do {
            try await goalService.saveProgress(progress)
            await loadProgress()
        } catch {
            logger.error("Failed to update progress: \(error)")
            throw error
        }
    }

    public func deleteGoal(_ goal: Goal) async throws {
        logger.info("Deleting goal: \(goal.id)")

        do {
            try await goalService.deleteGoal(goal.id)
            await loadGoals()
        } catch {
            logger.error("Failed to delete goal: \(error)")
            throw error
        }
    }

    public func loadGoals() async {
        do {
            currentGoals = try await goalService.getAllGoals()
        } catch {
            logger.error("Failed to load goals: \(error)")
        }
    }

    public func loadProgress() async {
        do {
            weeklyProgress = try await goalService.getWeeklyProgress()
        } catch {
            logger.error("Failed to load progress: \(error)")
        }
    }
}

// MARK: - Goal Progress Helpers

@available(iOS 13.0, *)
public extension GoalManager {
    func getProgress(for goal: Goal) -> Double {
        let total = weeklyProgress
            .filter { $0.goalId == goal.id }
            .reduce(0) { $0 + $1.value }

        return min(total / goal.targetValue, 1.0)
    }

    func getProgressPercentage(for goal: Goal) -> Int {
        Int(getProgress(for: goal) * 100)
    }

    func isGoalCompleted(_ goal: Goal) -> Bool {
        getProgress(for: goal) >= 1.0
    }
}

// MARK: - Workout Integration

@available(iOS 13.0, *)
public extension GoalManager {
    func processWorkoutCompletion(_ session: WorkoutSession) async throws {
        logger.info("Processing workout completion for goal updates")

        let relevantGoals = getRelevantGoals(for: session.type)

        for goal in relevantGoals {
            guard let progressValue = progressValue(for: goal, session: session) else {
                continue
            }

            try await updateProgress(for: goal.id, value: progressValue)
        }

        logger.info("Completed goal progress updates for \(relevantGoals.count) goals")
    }

    private func progressValue(for goal: Goal, session: WorkoutSession) -> Double? {
        switch goal.type {
        case .workoutCount:
            return 1.0
        case .totalDuration:
            return session.durationInMinutes
        case .calories:
            return Double(session.estimatedCalories)
        case .distance:
            return session.estimatedDistance
        case .steps:
            return session.estimatedSteps.map(Double.init)
        case .specificWorkout:
            return goal.targetWorkoutType == session.type ? 1.0 : nil
        }
    }

    func getRelevantGoals(for workoutType: WorkoutType) -> [Goal] {
        currentGoals.filter { $0.isActive && $0.appliesTo(workoutType: workoutType) }
    }

    func getSuggestedGoals(for workoutType: WorkoutType) -> [GoalType] {
        workoutType.applicableGoalTypes
    }
}

