//
//  ExerciseLibrary.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI

struct Exercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var stationType: StationType
    var difficulty: ExerciseDifficulty
    var muscleGroups: [MuscleGroup]
    var defaultReps: Int?
    var defaultTime: TimeInterval?
    var defaultRest: TimeInterval
    var tips: [String]
    var videoURL: String?
    
    init(id: UUID = UUID(), name: String, description: String, stationType: StationType, difficulty: ExerciseDifficulty = .beginner, muscleGroups: [MuscleGroup] = [], defaultReps: Int? = nil, defaultTime: TimeInterval? = nil, defaultRest: TimeInterval = 60, tips: [String] = [], videoURL: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.stationType = stationType
        self.difficulty = difficulty
        self.muscleGroups = muscleGroups
        self.defaultReps = defaultReps
        self.defaultTime = defaultTime
        self.defaultRest = defaultRest
        self.tips = tips
        self.videoURL = videoURL
    }
}

enum ExerciseDifficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"
    case fullBody = "Full Body"
    
    var icon: String {
        switch self {
        case .chest: return "figure.arms.open"
        case .back: return "figure.stand"
        case .shoulders: return "figure.flexibility"
        case .arms: return "figure.strengthtraining.traditional"
        case .legs: return "figure.run"
        case .core: return "figure.core.training"
        case .cardio: return "heart.fill"
        case .fullBody: return "figure.mixed.cardio"
        }
    }
}

class ExerciseLibrary {
    static let shared = ExerciseLibrary()
    
    private init() {}
    
    var exercises: [Exercise] {
        [
            // Kettlebell exercises
            Exercise(
                name: "Kettlebell Swing",
                description: "Explosive hip-hinge movement that targets the posterior chain",
                stationType: .kettlebell,
                difficulty: .intermediate,
                muscleGroups: [.legs, .core, .back],
                defaultReps: 20,
                defaultRest: 60,
                tips: ["Keep your back straight", "Drive with your hips", "Let the bell float to chest height"]
            ),
            Exercise(
                name: "Kettlebell Goblet Squat",
                description: "Front-loaded squat holding the kettlebell at chest level",
                stationType: .kettlebell,
                difficulty: .beginner,
                muscleGroups: [.legs, .core],
                defaultReps: 15,
                defaultRest: 60,
                tips: ["Keep your chest up", "Sit back into your heels", "Full depth if possible"]
            ),
            Exercise(
                name: "Turkish Get-Up",
                description: "Complex movement from lying to standing while holding a kettlebell",
                stationType: .kettlebell,
                difficulty: .advanced,
                muscleGroups: [.fullBody, .core],
                defaultTime: 60,
                defaultRest: 90,
                tips: ["Move slowly and controlled", "Keep your eyes on the bell", "Practice without weight first"]
            ),
            
            // Pull-up Bar exercises
            Exercise(
                name: "Pull-Ups",
                description: "Upper body pulling exercise targeting back and arms",
                stationType: .pullUpBar,
                difficulty: .intermediate,
                muscleGroups: [.back, .arms],
                defaultReps: 10,
                defaultRest: 90,
                tips: ["Full range of motion", "Control the descent", "Engage your core"]
            ),
            Exercise(
                name: "Hanging Leg Raises",
                description: "Core exercise performed while hanging from a pull-up bar",
                stationType: .pullUpBar,
                difficulty: .intermediate,
                muscleGroups: [.core],
                defaultReps: 12,
                defaultRest: 60,
                tips: ["Control the movement", "Avoid swinging", "Breathe out as you raise"]
            ),
            Exercise(
                name: "Chin-Ups",
                description: "Pull-up variation with palms facing you",
                stationType: .pullUpBar,
                difficulty: .beginner,
                muscleGroups: [.back, .arms],
                defaultReps: 8,
                defaultRest: 90,
                tips: ["Easier than pull-ups", "Focus on biceps", "Full extension at bottom"]
            ),
            
            // Mat exercises
            Exercise(
                name: "Burpees",
                description: "Full-body exercise combining squat, plank, and jump",
                stationType: .mat,
                difficulty: .intermediate,
                muscleGroups: [.fullBody, .cardio],
                defaultReps: 10,
                defaultRest: 60,
                tips: ["Maintain good form", "Land softly", "Keep core engaged"]
            ),
            Exercise(
                name: "Push-Ups",
                description: "Classic upper body pushing exercise",
                stationType: .mat,
                difficulty: .beginner,
                muscleGroups: [.chest, .arms, .shoulders],
                defaultReps: 15,
                defaultRest: 60,
                tips: ["Keep body straight", "Full range of motion", "Control the movement"]
            ),
            Exercise(
                name: "Plank",
                description: "Isometric core strengthening exercise",
                stationType: .mat,
                difficulty: .beginner,
                muscleGroups: [.core],
                defaultTime: 60,
                defaultRest: 30,
                tips: ["Keep body straight", "Don't let hips sag", "Breathe normally"]
            ),
            
            // Box exercises
            Exercise(
                name: "Box Jumps",
                description: "Plyometric exercise jumping onto a box",
                stationType: .box,
                difficulty: .intermediate,
                muscleGroups: [.legs, .cardio],
                defaultReps: 12,
                defaultRest: 90,
                tips: ["Land softly", "Full extension on jump", "Step down, don't jump down"]
            ),
            Exercise(
                name: "Step-Ups",
                description: "Single-leg stepping exercise onto a box",
                stationType: .box,
                difficulty: .beginner,
                muscleGroups: [.legs],
                defaultReps: 10,
                defaultRest: 60,
                tips: ["Drive through the heel", "Keep chest up", "Alternate legs"]
            ),
            
            // Rope exercises
            Exercise(
                name: "Battle Ropes",
                description: "High-intensity exercise using heavy ropes",
                stationType: .rope,
                difficulty: .advanced,
                muscleGroups: [.fullBody, .cardio],
                defaultTime: 30,
                defaultRest: 90,
                tips: ["Maintain good posture", "Use your whole body", "Control the waves"]
            ),
            Exercise(
                name: "Rope Climbing",
                description: "Upper body and core exercise climbing a rope",
                stationType: .rope,
                difficulty: .advanced,
                muscleGroups: [.back, .arms, .core],
                defaultReps: 3,
                defaultRest: 120,
                tips: ["Use your legs too", "Grip tightly", "Control the descent"]
            )
        ]
    }
    
    func exercises(for stationType: StationType) -> [Exercise] {
        exercises.filter { $0.stationType == stationType }
    }
    
    func exercises(for muscleGroup: MuscleGroup) -> [Exercise] {
        exercises.filter { $0.muscleGroups.contains(muscleGroup) }
    }
}
