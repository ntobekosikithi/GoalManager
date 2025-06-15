//
//  EmptyGoalsView.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//
import SwiftUI

@available(iOS 14.0, *)
struct EmptyGoalsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Goals Yet")
                .font(.headline)
            
            Text("Set your first fitness goal to start tracking your progress")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
