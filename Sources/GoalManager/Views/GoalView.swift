//
//  GoalView.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/13.
//

import SwiftUI
import WorkoutTracker

@available(iOS 15.0, *)
public struct GoalView: View {
    @StateObject private var goalManager = GoalManager()
    @State private var showingCreateGoal = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if goalManager.goals.isEmpty {
                    emptyStateView
                } else {
                    goalsList
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateGoal) {
                CreateGoalView(goalManager: goalManager)
            }
            .onAppear {
                goalManager.updateGoalProgress()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Goals Set")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first fitness goal to start tracking your progress!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Goal") {
                showingCreateGoal = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
    
    private var goalsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(goalManager.getActiveGoals()) { goal in
                    GoalCard(
                        goal: goal,
                        progress: goalManager.getGoalProgress(for: goal),
                        onDelete: {
                            goalManager.deleteGoal(goal)
                        }
                    )
                }
                
                if !goalManager.getCompletedGoals().isEmpty {
                    completedGoalsSection
                }
            }
            .padding()
        }
    }
    
    private var completedGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Completed Goals")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(goalManager.getCompletedGoals()) { goal in
                CompletedGoalCard(goal: goal) {
                    goalManager.deleteGoal(goal)
                }
            }
        }
    }
}

// MARK: - Supporting Views

@available(iOS 14.0, *)
private struct GoalCard: View {
    let goal: Goal
    let progress: GoalProgress
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.type.icon)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.type.rawValue)
                        .font(.headline)
                    
                    Text(goal.period.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(Int(goal.currentValue)) / \(Int(goal.targetValue)) \(goal.type.unit)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(goal.progressPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
                
                ProgressView(value: goal.progressPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            
            // Status and motivation
            VStack(alignment: .leading, spacing: 4) {
                Text(progress.statusText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(progressColor)
                
                Text(progress.motivationalMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if progress.daysRemaining > 0 {
                Text("\(progress.daysRemaining) days remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private var progressColor: Color {
        if goal.isCompleted {
            return .green
        } else if progress.isOnTrack {
            return .blue
        } else {
            return .orange
        }
    }
}

@available(iOS 14.0, *)
private struct CompletedGoalCard: View {
    let goal: Goal
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Completed \(goal.createdAt.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.1))
        )
    }
}

@available(iOS 15.0, *)
private struct CreateGoalView: View {
    @ObservedObject var goalManager: GoalManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: GoalType = .workoutCount
    @State private var targetValue: Double = 5
    @State private var selectedPeriod: GoalPeriod = .weekly
    
    var body: some View {
        NavigationView {
            Form {
                Section("Goal Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Target") {
                    HStack {
                        Text("Target Value")
                        Spacer()
                        Text("\(Int(targetValue)) \(selectedType.unit)")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $targetValue, in: 1...30, step: 1)
                }
                
                Section("Period") {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(GoalPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("Create Goal") {
                        goalManager.createGoal(
                            type: selectedType,
                            targetValue: targetValue,
                            period: selectedPeriod
                        )
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

@available(iOS 15.0, *)
#Preview {
    GoalView()
}
