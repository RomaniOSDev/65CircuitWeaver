//
//  ExerciseLibraryView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct ExerciseLibraryView: View {
    @State private var selectedStationType: StationType?
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var searchText = ""
    @State private var selectedExercise: Exercise?
    
    private var filteredExercises: [Exercise] {
        var exercises = ExerciseLibrary.shared.exercises
        
        if let stationType = selectedStationType {
            exercises = exercises.filter { $0.stationType == stationType }
        }
        
        if let muscleGroup = selectedMuscleGroup {
            exercises = exercises.filter { $0.muscleGroups.contains(muscleGroup) }
        }
        
        if !searchText.isEmpty {
            exercises = exercises.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return exercises
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filters
                    VStack(spacing: 12) {
                        // Search
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.cwStation.opacity(0.5))
                            TextField("Search exercises...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        // Station type filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                FilterChip(
                                    title: "All",
                                    isSelected: selectedStationType == nil
                                ) {
                                    selectedStationType = nil
                                }
                                
                                ForEach(StationType.allCases, id: \.self) { type in
                                    FilterChip(
                                        title: type.displayName,
                                        isSelected: selectedStationType == type
                                    ) {
                                        selectedStationType = selectedStationType == type ? nil : type
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Muscle group filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                FilterChip(
                                    title: "All Groups",
                                    isSelected: selectedMuscleGroup == nil
                                ) {
                                    selectedMuscleGroup = nil
                                }
                                
                                ForEach(MuscleGroup.allCases, id: \.self) { group in
                                    FilterChip(
                                        title: group.rawValue,
                                        isSelected: selectedMuscleGroup == group
                                    ) {
                                        selectedMuscleGroup = selectedMuscleGroup == group ? nil : group
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Exercises list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredExercises) { exercise in
                                ExerciseCard(exercise: exercise) {
                                    selectedExercise = exercise
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }
}

struct ExerciseCard: View {
    let exercise: Exercise
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: exercise.stationType.iconName)
                        .foregroundColor(.cwActiveFlow)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        HStack {
                            Text(exercise.difficulty.rawValue)
                                .font(.caption)
                                .foregroundColor(exercise.difficulty.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(exercise.difficulty.color.opacity(0.2))
                                .cornerRadius(8)
                            
                            ForEach(exercise.muscleGroups.prefix(3), id: \.self) { group in
                                Text(group.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(.cwStation.opacity(0.7))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.cwBackground)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                Text(exercise.description)
                    .font(.subheadline)
                    .foregroundColor(.cwStation.opacity(0.7))
                    .lineLimit(2)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.white, Color.white.opacity(0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [Color.cwActiveFlow.opacity(0.15), Color.cwActiveFlow.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.cwActiveFlow.opacity(0.2), radius: 12, x: 0, y: 6)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: exercise.stationType.iconName)
                            .font(.system(size: 50))
                            .foregroundColor(.cwActiveFlow)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.name)
                                .font(.title)
                                .foregroundColor(.cwStation)
                            
                            HStack {
                                Text(exercise.difficulty.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(exercise.difficulty.color)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(exercise.difficulty.color.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        Text(exercise.description)
                            .font(.body)
                            .foregroundColor(.cwStation.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Muscle Groups
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Target Muscles")
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(exercise.muscleGroups, id: \.self) { group in
                                HStack {
                                    Image(systemName: group.icon)
                                        .foregroundColor(.cwActiveFlow)
                                    Text(group.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.cwStation)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.cwBackground)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Default Parameters
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Parameters")
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        HStack(spacing: 20) {
                            if let reps = exercise.defaultReps {
                                VStack(alignment: .leading) {
                                    Text("Reps")
                                        .font(.caption)
                                        .foregroundColor(.cwStation.opacity(0.7))
                                    Text("\(reps)")
                                        .font(.title3)
                                        .foregroundColor(.cwActiveFlow)
                                }
                            }
                            
                            if let time = exercise.defaultTime {
                                VStack(alignment: .leading) {
                                    Text("Time")
                                        .font(.caption)
                                        .foregroundColor(.cwStation.opacity(0.7))
                                    Text("\(Int(time))s")
                                        .font(.title3)
                                        .foregroundColor(.cwActiveFlow)
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Rest")
                                    .font(.caption)
                                    .foregroundColor(.cwStation.opacity(0.7))
                                Text("\(Int(exercise.defaultRest))s")
                                    .font(.title3)
                                    .foregroundColor(.cwActiveFlow)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Tips
                    if !exercise.tips.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tips")
                                .font(.headline)
                                .foregroundColor(.cwStation)
                            
                            ForEach(Array(exercise.tips.enumerated()), id: \.offset) { index, tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1).")
                                        .font(.subheadline)
                                        .foregroundColor(.cwActiveFlow)
                                    Text(tip)
                                        .font(.subheadline)
                                        .foregroundColor(.cwStation.opacity(0.8))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.cwBackground)
            .navigationTitle("Exercise Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cwActiveFlow)
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .cwStation)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.cwActiveFlow : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.cwStation.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    ExerciseLibraryView()
}
