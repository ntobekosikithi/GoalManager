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
                goalDetailsSection
                goalTypeSection
                goalTargetSection
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveGoal)
                        .disabled(title.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Sections

    private var goalDetailsSection: some View {
        Section("Goal Details") {
            TextField("Goal Title", text: $title)

            TextEditor(text: $description)
                .frame(height: 100)
        }
    }

    private var goalTypeSection: some View {
        Section("Goal Type") {
            Picker("Type", selection: $selectedType) {
                ForEach(GoalType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.systemImage)
                        .tag(type)
                }
            }
        }
    }

    private var goalTargetSection: some View {
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

    // MARK: - Logic

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
