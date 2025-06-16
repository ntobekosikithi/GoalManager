//
//  AddGoalView.swift
//  GoalManager
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import SwiftUI
import Utilities

@available(iOS 15.0, *)
struct AddGoalView: View {
    @ObservedObject var goalManager: GoalManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType: GoalType = .workoutCount
    @State private var targetValue: Double = 5
    @State private var targetDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }

                Section("Goal Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.systemImage)
                                .tag(type)
                        }
                    }
                }

                Section("Target") {
                    HStack {
                        Text("Target Value")
                        Spacer()
                        TextField("Value", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(selectedType.defaultUnit)
                            .foregroundColor(.secondary)
                    }

                    DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty)
                }
            })
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveGoal() {
        let goal = Goal(
            title: title,
            description: description,
            type: selectedType,
            targetValue: targetValue,
            unit: selectedType.defaultUnit,
            targetDate: targetDate
        )
        
        Task {
            do {
                try await goalManager.setGoal(goal)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}
