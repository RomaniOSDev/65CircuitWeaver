//
//  TrainingProgram.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

struct TrainingProgram: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var difficulty: ExerciseDifficulty
    var duration: Int // weeks
    var frequency: Int // sessions per week
    var circuits: [ProgramCircuit]
    var goals: [ProgramGoal]
    var isCustom: Bool
    var createdBy: String?
    
    init(id: UUID = UUID(), name: String, description: String, difficulty: ExerciseDifficulty, duration: Int, frequency: Int, circuits: [ProgramCircuit] = [], goals: [ProgramGoal] = [], isCustom: Bool = false, createdBy: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.duration = duration
        self.frequency = frequency
        self.circuits = circuits
        self.goals = goals
        self.isCustom = isCustom
        self.createdBy = createdBy
    }
}

struct ProgramCircuit: Identifiable, Codable {
    let id: UUID
    var week: Int // Which week this circuit is for
    var circuitTemplate: CircuitTemplate
    var progression: ProgressionType
    
    init(id: UUID = UUID(), week: Int, circuitTemplate: CircuitTemplate, progression: ProgressionType = .none) {
        self.id = id
        self.week = week
        self.circuitTemplate = circuitTemplate
        self.progression = progression
    }
}

struct CircuitTemplate: Codable {
    var name: String
    var stations: [TemplateStation]
    var rounds: Int
    var restBetweenRounds: TimeInterval
    
    init(name: String, stations: [TemplateStation], rounds: Int, restBetweenRounds: TimeInterval = 120) {
        self.name = name
        self.stations = stations
        self.rounds = rounds
        self.restBetweenRounds = restBetweenRounds
    }
}

struct TemplateStation: Identifiable, Codable {
    let id: UUID
    var stationType: StationType
    var exerciseName: String
    var reps: Int?
    var time: TimeInterval?
    var restAfter: TimeInterval
    
    init(id: UUID = UUID(), stationType: StationType, exerciseName: String, reps: Int? = nil, time: TimeInterval? = nil, restAfter: TimeInterval = 60) {
        self.id = id
        self.stationType = stationType
        self.exerciseName = exerciseName
        self.reps = reps
        self.time = time
        self.restAfter = restAfter
    }
}

enum ProgressionType: String, Codable {
    case none = "None"
    case increaseReps = "Increase Reps"
    case increaseTime = "Increase Time"
    case decreaseRest = "Decrease Rest"
    case addRounds = "Add Rounds"
}

enum ProgramGoal: String, Codable, CaseIterable {
    case strength = "Strength"
    case endurance = "Endurance"
    case weightLoss = "Weight Loss"
    case muscleGain = "Muscle Gain"
    case generalFitness = "General Fitness"
    case flexibility = "Flexibility"
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .endurance: return "figure.run"
        case .weightLoss: return "scalemass.fill"
        case .muscleGain: return "figure.strengthtraining.traditional"
        case .generalFitness: return "heart.fill"
        case .flexibility: return "figure.flexibility"
        }
    }
}

class TrainingProgramLibrary {
    static let shared = TrainingProgramLibrary()
    
    private init() {}
    
    var programs: [TrainingProgram] {
        [
            TrainingProgram(
                name: "Beginner Full Body",
                description: "Perfect for those just starting their fitness journey",
                difficulty: .beginner,
                duration: 4,
                frequency: 3,
                circuits: [
                    ProgramCircuit(
                        week: 1,
                        circuitTemplate: CircuitTemplate(
                            name: "Full Body Circuit",
                            stations: [
                                TemplateStation(stationType: .mat, exerciseName: "Push-Ups", reps: 10),
                                TemplateStation(stationType: .mat, exerciseName: "Bodyweight Squats", reps: 15),
                                TemplateStation(stationType: .mat, exerciseName: "Plank", time: 30),
                                TemplateStation(stationType: .mat, exerciseName: "Jumping Jacks", reps: 20)
                            ],
                            rounds: 3
                        ),
                        progression: .increaseReps
                    )
                ],
                goals: [.generalFitness, .strength]
            ),
            TrainingProgram(
                name: "Strength Builder",
                description: "Build functional strength with compound movements",
                difficulty: .intermediate,
                duration: 6,
                frequency: 4,
                circuits: [
                    ProgramCircuit(
                        week: 1,
                        circuitTemplate: CircuitTemplate(
                            name: "Strength Circuit",
                            stations: [
                                TemplateStation(stationType: .kettlebell, exerciseName: "Kettlebell Swing", reps: 20),
                                TemplateStation(stationType: .pullUpBar, exerciseName: "Pull-Ups", reps: 8),
                                TemplateStation(stationType: .box, exerciseName: "Box Jumps", reps: 12),
                                TemplateStation(stationType: .kettlebell, exerciseName: "Goblet Squat", reps: 15)
                            ],
                            rounds: 4
                        ),
                        progression: .increaseReps
                    )
                ],
                goals: [.strength, .muscleGain]
            ),
            TrainingProgram(
                name: "Cardio Blast",
                description: "High-intensity cardio workout for fat burning",
                difficulty: .intermediate,
                duration: 4,
                frequency: 5,
                circuits: [
                    ProgramCircuit(
                        week: 1,
                        circuitTemplate: CircuitTemplate(
                            name: "Cardio Circuit",
                            stations: [
                                TemplateStation(stationType: .mat, exerciseName: "Burpees", reps: 10),
                                TemplateStation(stationType: .rope, exerciseName: "Battle Ropes", time: 30),
                                TemplateStation(stationType: .box, exerciseName: "Box Jumps", reps: 15),
                                TemplateStation(stationType: .mat, exerciseName: "Mountain Climbers", reps: 20)
                            ],
                            rounds: 5
                        ),
                        progression: .decreaseRest
                    )
                ],
                goals: [.weightLoss, .endurance]
            )
        ]
    }
}
