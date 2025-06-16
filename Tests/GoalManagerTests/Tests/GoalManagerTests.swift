
import Testing
import Foundation
@testable import Utilities
@testable import GoalManager

@Suite("GoalManager Tests")

@MainActor
struct GoalManagerTests {
    
    var mockGoalService: MockGoalService
    var mockLogger: MockLogger
    
    init() {
        mockGoalService = MockGoalService()
        mockLogger = MockLogger()
    }

    private func createGoalManager() -> GoalManager {
        return GoalManager(goalService: mockGoalService, logger: mockLogger)
    }
    
    // MARK: - Goal CRUD Tests
    
    @Test("Set goal successfully")
    func setGoalSuccess() async throws {
        // Given
        let goalManager = createGoalManager()
        let goal = createSampleGoal(title: "Test Goal")
        
        // When
        try await goalManager.setGoal(goal)
        
        // Then
        #expect(mockGoalService.saveGoalCallCount == 1)
        #expect(mockGoalService.lastSavedGoal?.title == "Test Goal")
        #expect(mockGoalService.getAllGoalsCallCount == 1)
        #expect(mockLogger.infoMessages.contains { $0.contains("Setting goal: Test Goal") })
    }
    
    @Test("Set goal with failure")
    func setGoalFailure() async {
        // Given
        let goalManager = createGoalManager()
        let goal = createSampleGoal(title: "Test Goal")
        mockGoalService.shouldThrowError = true
        
        // When & Then
        await #expect(throws: MockError.testError) {
            try await goalManager.setGoal(goal)
        }
        
        #expect(mockGoalService.saveGoalCallCount == 1)
        #expect(mockGoalService.getAllGoalsCallCount == 0)
        #expect(mockLogger.errorMessages.contains { $0.contains("Failed to set goal: Test Goal") })
    }
    
    @Test("Delete goal successfully")
    func deleteGoalSuccess() async throws {
        // Given
        let goalManager = createGoalManager()
        let goal = createSampleGoal(title: "Test Goal")
        
        // When
        try await goalManager.deleteGoal(goal)
        
        // Then
        #expect(mockGoalService.deleteGoalCallCount == 1)
        #expect(mockGoalService.lastDeletedGoalId == goal.id)
        #expect(mockGoalService.getAllGoalsCallCount == 1)
        #expect(mockLogger.infoMessages.contains { $0.contains("Deleting goal: \(goal.id)") })
    }
    
    @Test("Delete goal with failure")
    func deleteGoalFailure() async {
        // Given
        let goalManager = createGoalManager()
        let goal = createSampleGoal(title: "Test Goal")
        mockGoalService.shouldThrowError = true
        
        // When & Then
        await #expect(throws: MockError.testError) {
            try await goalManager.deleteGoal(goal)
        }
        
        #expect(mockGoalService.deleteGoalCallCount == 1)
        #expect(mockGoalService.getAllGoalsCallCount == 0)
        #expect(mockLogger.errorMessages.contains { $0.contains("Failed to delete goal: \(goal.id)") })
    }
    
    @Test("Load goals successfully")
    func loadGoalsSuccess() async {
        // Given
        let goalManager = createGoalManager()
        let goals = [
            createSampleGoal(title: "Goal 1"),
            createSampleGoal(title: "Goal 2")
        ]
        mockGoalService.goalsToReturn = goals
        
        // When
        await goalManager.loadGoals()
        
        // Then
        await MainActor.run {
            #expect(goalManager.currentGoals.count == 2)
            #expect(goalManager.currentGoals[0].title == "Goal 1")
            #expect(goalManager.currentGoals[1].title == "Goal 2")
        }
        #expect(mockGoalService.getAllGoalsCallCount == 1)
    }
    
    @Test("Load goals with failure")
    func loadGoalsFailure() async {
        // Given
        let goalManager = createGoalManager()
        mockGoalService.shouldThrowError = true
        
        // When
        await goalManager.loadGoals()
        
        // Then
        await MainActor.run {
            #expect(goalManager.currentGoals.count == 0)
        }
        #expect(mockGoalService.getAllGoalsCallCount == 1)
        #expect(mockLogger.errorMessages.contains { $0.contains("Failed to load goals") })
    }
    
    // MARK: - Progress Update Tests
    
    @Test("Update progress successfully")
    func updateProgressSuccess() async throws {
        // Given
        let goalManager = createGoalManager()
        let goalId = UUID()
        let progressValue = 5.0
        
        // When
        try await goalManager.updateProgress(for: goalId, value: progressValue)
        
        // Then
        #expect(mockGoalService.saveProgressCallCount == 1)
        #expect(mockGoalService.lastSavedProgress?.goalId == goalId)
        #expect(mockGoalService.lastSavedProgress?.value == progressValue)
        #expect(mockGoalService.getWeeklyProgressCallCount == 1)
        #expect(mockLogger.infoMessages.contains { $0.contains("Updating progress for goal: \(goalId)") })
    }
    
    @Test("Update progress with default value")
    func updateProgressDefaultValue() async throws {
        // Given
        let goalManager = createGoalManager()
        let goalId = UUID()
        
        // When
        try await goalManager.updateProgress(for: goalId)
        
        // Then
        #expect(mockGoalService.lastSavedProgress?.value == 0.0)
    }
    
    @Test("Update progress with nil value")
    func updateProgressNilValue() async throws {
        // Given
        let goalManager = createGoalManager()
        let goalId = UUID()
        
        // When
        try await goalManager.updateProgress(for: goalId, value: nil)
        
        // Then
        #expect(mockGoalService.lastSavedProgress?.value == 0.0)
    }
    
    @Test("Update progress with failure")
    func updateProgressFailure() async {
        // Given
        let goalManager = createGoalManager()
        let goalId = UUID()
        mockGoalService.shouldThrowError = true
        
        // When & Then
        await #expect(throws: MockError.testError) {
            try await goalManager.updateProgress(for: goalId, value: 5.0)
        }
        
        #expect(mockGoalService.saveProgressCallCount == 1)
        #expect(mockGoalService.getWeeklyProgressCallCount == 0)
        #expect(mockLogger.errorMessages.contains { $0.contains("Failed to update progress for goal: \(goalId)") })
    }
    
    @Test("Load progress successfully")
    func loadProgressSuccess() async {
        // Given
        let goalManager = createGoalManager()
        let progress = [
            GoalProgress(id: UUID(), goalId: UUID(), value: 5.0, date: Date()),
            GoalProgress(id: UUID(), goalId: UUID(), value: 3.0, date: Date())
        ]
        mockGoalService.progressToReturn = progress
        
        // When
        await goalManager.loadProgress()
        
        // Then
        await MainActor.run {
            #expect(goalManager.weeklyProgress.count == 2)
            #expect(goalManager.weeklyProgress[0].value == 5.0)
            #expect(goalManager.weeklyProgress[1].value == 3.0)
        }
        #expect(mockGoalService.getWeeklyProgressCallCount == 1)
    }
    
    @Test("Load progress with failure")
    func loadProgressFailure() async {
        // Given
        let goalManager = createGoalManager()
        mockGoalService.shouldThrowError = true
        
        // When
        await goalManager.loadProgress()
        
        // Then
        await MainActor.run {
            #expect(goalManager.weeklyProgress.count == 0)
        }
        #expect(mockGoalService.getWeeklyProgressCallCount == 1)
        #expect(mockLogger.errorMessages.contains { $0.contains("Failed to load progress") })
    }
    
//    // MARK: - Progress Helper Tests
    
    @Test("Get progress calculation")
    func getProgress() async {
        // Given
        let goalManager = createGoalManager()
        let goalId = UUID()
        let goal = createSampleGoal(id: goalId, targetValue: 10.0)
        let progress = [
            GoalProgress(id: UUID(), goalId: goalId, value: 3.0, date: Date()),
            GoalProgress(id: UUID(), goalId: goalId, value: 2.0, date: Date()),
            GoalProgress(id: UUID(), goalId: UUID(), value: 5.0, date: Date()) // Different goal
        ]
        
        mockGoalService.progressToReturn = progress
        await goalManager.loadProgress()
        
        // When
        let result = await MainActor.run {
            goalManager.getProgress(for: goal)
        }
        
        // Then
        #expect(abs(result - 0.5) < 0.001) // (3.0 + 2.0) / 10.0 = 0.5
    }
    
    @Test("Get progress exceeds target")
    func getProgressExceedsTarget() async {
        // Given
        let goalManager = createGoalManager()
        let goalId = UUID()
        let goal = createSampleGoal(id: goalId, targetValue: 5.0)
        let progress = [
            GoalProgress(id: UUID(), goalId: goalId, value: 8.0, date: Date())
        ]
        
        mockGoalService.progressToReturn = progress
        await goalManager.loadProgress()
        
        // When
        let result = await MainActor.run {
            goalManager.getProgress(for: goal)
        }
        
        // Then
        #expect(result == 1.0) // Capped at 1.0
    }
    
    @Test("Get progress percentage")
    func getProgressPercentage() async {
        // Given
        let goalManager = createGoalManager()
        let goalId = UUID()
        let goal = createSampleGoal(id: goalId, targetValue: 10.0)
        let progress = [
            GoalProgress(id: UUID(), goalId: goalId, value: 7.5, date: Date())
        ]
        
        mockGoalService.progressToReturn = progress
        await goalManager.loadProgress()
        
        // When
        let result = await MainActor.run {
            goalManager.getProgressPercentage(for: goal)
        }
        
        // Then
        #expect(result == 75) // 7.5 / 10.0 * 100 = 75%
    }
    
    @Test("Goal is completed")
    func isGoalCompletedTrue() async {
        // Given
        let goalManager = createGoalManager()
        let goalId = UUID()
        let goal = createSampleGoal(id: goalId, targetValue: 10.0)
        let progress = [
            GoalProgress(id: UUID(), goalId: goalId, value: 10.0, date: Date())
        ]
        
        mockGoalService.progressToReturn = progress
        await goalManager.loadProgress()
        
        // When
        let result = await MainActor.run {
            goalManager.isGoalCompleted(goal)
        }
        
        // Then
        #expect(result == true)
    }
    
    @Test("Goal is not completed")
    func isGoalCompletedFalse() async {
        // Given
        let goalManager = createGoalManager()
        let goalId = UUID()
        let goal = createSampleGoal(id: goalId, targetValue: 10.0)
        let progress = [
            GoalProgress(id: UUID(), goalId: goalId, value: 9.0, date: Date())
        ]
        
        mockGoalService.progressToReturn = progress
        await goalManager.loadProgress()
        
        // When
        let result = await MainActor.run {
            goalManager.isGoalCompleted(goal)
        }
        
        // Then
        #expect(result == false)
    }
    
    // MARK: - Workout Integration Tests
    
    @Test("Process workout completion")
    func processWorkoutCompletion() async throws {
        // Given
        let goalManager = createGoalManager()
        let workoutSession = createSampleWorkoutSession(
            type: .running,
            duration: 1800, // 30 minutes
            calories: 300,
            distance: 5.0,
            steps: 4000
        )
        
        let goals = [
            createSampleGoal(type: .workoutCount, targetValue: 5.0),
            createSampleGoal(type: .totalDuration, targetValue: 60.0),
            createSampleGoal(type: .calories, targetValue: 1000.0),
            createSampleGoal(type: .distance, targetValue: 20.0),
            createSampleGoal(type: .steps, targetValue: 10000.0)
        ]
        
        mockGoalService.goalsToReturn = goals
        await goalManager.loadGoals()
        
        // When
        try await goalManager.processWorkoutCompletion(workoutSession)
        
        // Then
        #expect(mockGoalService.saveProgressCallCount == 5)
        #expect(mockLogger.infoMessages.contains { $0.contains("Processing workout completion for goal updates") })
        #expect(mockLogger.infoMessages.contains { $0.contains("Completed progress updates for 5 goals") })
    }
    
    @Test("Process workout completion for specific workout")
    func processWorkoutCompletionSpecificWorkout() async throws {
        // Given
        let goalManager = createGoalManager()
        let workoutSession = createSampleWorkoutSession(type: .running)
        
        let goals = [
            createSampleGoal(type: .specificWorkout, targetWorkoutType: .running),
            createSampleGoal(type: .specificWorkout, targetWorkoutType: .cycling)
        ]
        
        mockGoalService.goalsToReturn = goals
        await goalManager.loadGoals()
        
        // When
        try await goalManager.processWorkoutCompletion(workoutSession)
        
        // Then
        #expect(mockGoalService.saveProgressCallCount == 1) // Only running goal should be updated
    }
    
    @Test("Get relevant goals for workout type")
    func getRelevantGoals() async {
        // Given
        let goalManager = createGoalManager()
        let goals = [
            createSampleGoal(type: .workoutCount, isActive: true),
            createSampleGoal(type: .totalDuration, isActive: false),
            createSampleGoal(type: .specificWorkout, targetWorkoutType: .running, isActive: true),
            createSampleGoal(type: .specificWorkout, targetWorkoutType: .cycling, isActive: true)
        ]
        
        mockGoalService.goalsToReturn = goals
        await goalManager.loadGoals()
        
        // When
        let relevantGoals = await MainActor.run {
            goalManager.getRelevantGoals(for: .running)
        }
        
        // Then
        #expect(relevantGoals.count == 2) // workoutCount and running-specific goal
        #expect(relevantGoals.contains { $0.type == .workoutCount })
        #expect(relevantGoals.contains { $0.type == .specificWorkout && $0.targetWorkoutType == .running })
    }
    
    // MARK: - Helper Methods
    
    private func createSampleGoal(
        id: UUID = UUID(),
        title: String = "Sample Goal",
        type: GoalType = .workoutCount,
        targetValue: Double = 10.0,
        targetWorkoutType: WorkoutType? = nil,
        isActive: Bool = true
    ) -> Goal {
        return Goal(
            id: id,
            title: title,
            description: "Sample description",
            type: type,
            targetValue: targetValue,
            unit: "count",
            targetDate: Date().addingTimeInterval(86400 * 7), // 1 week from now
            isActive: isActive,
            targetWorkoutType: targetWorkoutType
        )
    }
    
    private func createSampleWorkoutSession(
        type: WorkoutType = .running,
        duration: TimeInterval = 1800,
        calories: Int? = 250,
        distance: Double? = 3.0,
        steps: Int? = 3000
    ) -> WorkoutSession {
        return WorkoutSession(
            id: UUID(),
            type: type,
            startTime: Date(),
            endTime: Date(),
            status: .completed,
            duration: duration,
            calories: calories,
            distance: distance,
            steps: steps
        )
    }
}
