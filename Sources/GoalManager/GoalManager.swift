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
        
        try await goalService.saveGoal(goal)
        await loadGoals()
    }
    
    public func updateProgress(for goalId: UUID, value: Double? = 0.0) async throws {
        logger.info("Updating progress for goal: \(goalId)")
        
        let progress = GoalProgress(
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

@available(iOS 13.0, *)
public extension GoalManager {
    func processWorkoutCompletion(_ session: WorkoutSession) async throws {
        logger.info("Processing workout completion for goal updates")
        
        let relevantGoals = currentGoals.filter { goal in
            goal.isActive && goal.appliesTo(workoutType: session.type)
        }
        
        for goal in relevantGoals {
            let progressValue: Double
            
            switch goal.type {
            case .workoutCount:
                progressValue = 1.0
                
            case .totalDuration:
                progressValue = session.durationInMinutes
                
            case .calories:
                progressValue = Double(session.estimatedCalories)
                
            case .distance:
                if let distance = session.estimatedDistance {
                    progressValue = distance
                } else {
                    continue
                }
                
            case .steps:
                if let steps = session.estimatedSteps {
                    progressValue = Double(steps)
                } else {
                    continue
                }
                
            case .specificWorkout:
                // For specific workout goals, only count if types match
                if goal.targetWorkoutType == session.type {
                    progressValue = 1.0
                } else {
                    continue
                }
            }
            
            try await updateProgress(for: goal.id, value: progressValue)
        }
        
        logger.info("Completed goal progress updates for \(relevantGoals.count) goals")
    }
    
    func getRelevantGoals(for workoutType: WorkoutType) -> [Goal] {
        return currentGoals.filter { goal in
            goal.isActive && goal.appliesTo(workoutType: workoutType)
        }
    }
    
    func getSuggestedGoals(for workoutType: WorkoutType) -> [GoalType] {
        return workoutType.applicableGoalTypes
    }
}
