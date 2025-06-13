// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine
import WorkoutTracker
import Utilities

@available(iOS 14.0, *)
@MainActor
public final class GoalManager: ObservableObject {
    @Published public private(set) var goals: [Goal] = []
    @Published public private(set) var isLoading = false
    
    private let workoutTracker: WorkoutTracker
    private var cancellables = Set<AnyCancellable>()
    
    public init(workoutTracker: WorkoutTracker = WorkoutTracker()) {
        self.workoutTracker = workoutTracker
        loadGoals()
        observeWorkoutChanges()
    }
    
    // MARK: - Public Interface
    
    public func createGoal(type: GoalType, targetValue: Double, period: GoalPeriod) {
        let goal = Goal(type: type, targetValue: targetValue, period: period)
        goals.append(goal)
        saveGoals()
        updateGoalProgress()
    }
    
    public func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    public func updateGoalProgress() {
        for index in goals.indices {
            goals[index].currentValue = calculateCurrentValue(for: goals[index])
        }
        saveGoals()
    }
    
    public func getActiveGoals() -> [Goal] {
        return goals.filter { goal in
            let now = Date()
            return now >= goal.period.startDate && now < goal.period.endDate
        }
    }
    
    public func getCompletedGoals() -> [Goal] {
        return goals.filter { $0.isCompleted }
    }
    
    public func getGoalProgress(for goal: Goal) -> GoalProgress {
        return GoalProgress(
            goal: goal,
            completionRate: goal.progressPercentage,
            daysRemaining: daysRemaining(for: goal),
            isOnTrack: isOnTrack(goal: goal)
        )
    }
    
    // MARK: - Private Methods
    
    private func observeWorkoutChanges() {
        workoutTracker.$workoutHistory
            .sink { [weak self] _ in
                self?.updateGoalProgress()
            }
            .store(in: &cancellables)
    }
    
    private func calculateCurrentValue(for goal: Goal) -> Double {
        let workouts = getWorkoutsInPeriod(for: goal)
        
        switch goal.type {
        case .workoutCount:
            return Double(workouts.count)
        case .totalDuration:
            return workouts.reduce(0) { $0 + $1.duration } / 60 // Convert to minutes
        case .specificWorkout:
            // For demo purposes, count all workouts. In real app, would filter by specific type
            return Double(workouts.count)
        case .weeklyActive:
            let uniqueDays = Set(workouts.map {
                Calendar.current.startOfDay(for: $0.startTime)
            })
            return Double(uniqueDays.count)
        }
    }
    
    private func getWorkoutsInPeriod(for goal: Goal) -> [Workout] {
        let startDate = goal.period.startDate
        let endDate = goal.period.endDate
        
        return workoutTracker.workoutHistory.filter { workout in
            workout.startTime >= startDate && workout.startTime < endDate
        }
    }
    
    private func daysRemaining(for goal: Goal) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let endDate = goal.period.endDate
        
        return calendar.dateComponents([.day], from: now, to: endDate).day ?? 0
    }
    
    private func isOnTrack(goal: Goal) -> Bool {
        let daysInPeriod: Int
        switch goal.period {
        case .daily: daysInPeriod = 1
        case .weekly: daysInPeriod = 7
        case .monthly: daysInPeriod = 30 // Approximate
        }
        
        let daysPassed = daysInPeriod - daysRemaining(for: goal)
        guard daysPassed > 0 else { return true }
        
        let expectedProgress = (Double(daysPassed) / Double(daysInPeriod)) * goal.targetValue
        return goal.currentValue >= expectedProgress * 0.8 // 80% threshold
    }
    
    private func saveGoals() {
        do {
            let data = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(data, forKey: "fitness_goals")
        } catch {
            print("Failed to save goals: \(error)")
        }
    }
    
    private func loadGoals() {
        guard let data = UserDefaults.standard.data(forKey: "fitness_goals") else { return }
        
        do {
            goals = try JSONDecoder().decode([Goal].self, from: data)
            updateGoalProgress()
        } catch {
            print("Failed to load goals: \(error)")
        }
    }
}

public struct GoalProgress {
    public let goal: Goal
    public let completionRate: Double
    public let daysRemaining: Int
    public let isOnTrack: Bool
    
    public var statusText: String {
        if goal.isCompleted {
            return "🎉 Goal Completed!"
        } else if isOnTrack {
            return "✅ On Track"
        } else {
            return "⚠️ Behind Schedule"
        }
    }
    
    public var motivationalMessage: String {
        if goal.isCompleted {
            return "Congratulations! You've achieved your goal!"
        } else if isOnTrack {
            return "Great progress! Keep it up!"
        } else {
            let remaining = goal.remainingValue
            return "You need \(Int(remaining)) more \(goal.type.unit) to reach your goal."
        }
    }
}
