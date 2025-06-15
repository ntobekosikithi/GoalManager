//
//  GoalCard.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import SwiftUI

@available(iOS 15.0, *)
struct GoalCard: View {
    let goal: Goal
    @ObservedObject var goalManager: GoalManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.type.systemImage)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(goal.title)
                        .font(.headline)
                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if goalManager.isGoalCompleted(goal) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(goalManager.getProgressPercentage(for: goal))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: goalManager.getProgress(for: goal))
                    .tint(.blue)
                
                HStack {
                    Text("Target: \(Int(goal.targetValue)) \(goal.unit)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Due: \(goal.targetDate.formatForDisplay())")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
