//
//  GoalView.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/13.
//

import SwiftUI

@available(iOS 15.0, *)
public struct GoalView: View {
    @StateObject private var goalManager = GoalManager()
    @State private var showingAddGoal = false
    public init(){}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(goalManager.currentGoals) { goal in
                        GoalCard(goal: goal, goalManager: goalManager)
                    }
                    
                    if goalManager.currentGoals.isEmpty {
                        EmptyGoalsView()
                    }
                }
                .padding()
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(goalManager: goalManager)
            }
        }
        .onAppear {
            Task {
                await goalManager.loadGoals()
                await goalManager.loadProgress()
            }
        }
    }
}
