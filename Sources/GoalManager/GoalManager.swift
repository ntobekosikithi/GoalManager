// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Utilities

@available(iOS 13.0, *)
@MainActor
public final class GoalManager: ObservableObject {
    @Published public private(set) var currentGoals: [Goal] = []
    @Published public private(set) var weeklyProgress: [Progress] = []
    
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
        
        try await goalService.saveGoal(goal)
        await loadGoals()
    }
    
    public func updateProgress(for goalId: UUID, value: Double? = 0.0) async throws {
        logger.info("Updating progress for goal: \(goalId)")
        
        let progress = Progress(
            id: UUID(),
            goalId: goalId,
            value: value ?? 0.0,
            date: Date()
        )
        
        try await goalService.saveProgress(progress)
        await loadProgress()
    }
    
    public func deleteGoal(_ goal: Goal) async throws {
        logger.info("Deleting goal: \(goal.id)")
        
        try await goalService.deleteGoal(goal.id)
        await loadGoals()
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

// MARK: - Public Interface
@available(iOS 13.0, *)
public extension GoalManager {
    func getProgress(for goal: Goal) -> Double {
        let goalProgress = weeklyProgress.filter { $0.goalId == goal.id }
        let totalProgress = goalProgress.reduce(0) { $0 + $1.value }
        return min(totalProgress / goal.targetValue, 1.0)
    }
    
    func getProgressPercentage(for goal: Goal) -> Int {
        Int(getProgress(for: goal) * 100)
    }
    
    func isGoalCompleted(_ goal: Goal) -> Bool {
        getProgress(for: goal) >= 1.0
    }
}
