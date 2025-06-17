//
//  GoalCard.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import SwiftUI
import Utilities

@available(iOS 15.0, *)
internal struct GoalCard: View {
    let goal: Goal
    @ObservedObject var goalManager: GoalManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Header
            HStack(alignment: .top) {
                Image(systemName: goal.type.systemImage)
                    .font(.title2)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(goal.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    if goalManager.isGoalCompleted(goal) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    }

                    Button {
                        Task {
                            try? await goalManager.deleteGoal(goal)
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                }
            }

            // MARK: - Progress Section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(goalManager.getProgressPercentage(for: goal))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                ProgressView(value: goalManager.getProgress(for: goal))
                    .tint(.blue)
                    .scaleEffect(x: 1.0, y: 1.2, anchor: .center)

                HStack {
                    Text("🎯 \(Int(goal.targetValue)) \(goal.unit)")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("📅 Due: \(goal.targetDate.formatForDisplay())")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
