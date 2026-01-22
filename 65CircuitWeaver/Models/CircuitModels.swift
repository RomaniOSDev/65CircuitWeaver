//
//  CircuitModels.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI

struct StationExercise: Identifiable, Codable {
    let id: UUID
    let stationId: UUID
    var exerciseName: String
    var reps: Int?
    var time: TimeInterval?
    var restAfter: TimeInterval
    
    init(id: UUID = UUID(), stationId: UUID, exerciseName: String, reps: Int? = nil, time: TimeInterval? = nil, restAfter: TimeInterval) {
        self.id = id
        self.stationId = stationId
        self.exerciseName = exerciseName
        self.reps = reps
        self.time = time
        self.restAfter = restAfter
    }
}

struct CircuitConnection: Identifiable, Codable {
    let id: UUID
    let fromStationId: UUID
    let toStationId: UUID
    var estimatedTransitionTime: TimeInterval
    
    init(id: UUID = UUID(), fromStationId: UUID, toStationId: UUID, estimatedTransitionTime: TimeInterval = 30.0) {
        self.id = id
        self.fromStationId = fromStationId
        self.toStationId = toStationId
        self.estimatedTransitionTime = estimatedTransitionTime
    }
    
    var path: Path? {
        nil // Will be calculated dynamically
    }
}

struct TrainingCircuit: Identifiable, Codable {
    let id: UUID
    var name: String
    var stations: [StationExercise]
    var connections: [CircuitConnection]
    var rounds: Int
    
    init(id: UUID = UUID(), name: String, stations: [StationExercise], connections: [CircuitConnection], rounds: Int) {
        self.id = id
        self.name = name
        self.stations = stations
        self.connections = connections
        self.rounds = rounds
    }
}

struct TrainingSpace: Identifiable, Codable {
    let id: UUID
    var name: String
    var stations: [Station]
    var obstacles: [Obstacle]?
    var circuits: [TrainingCircuit]
    
    init(id: UUID = UUID(), name: String, stations: [Station] = [], obstacles: [Obstacle]? = nil, circuits: [TrainingCircuit] = []) {
        self.id = id
        self.name = name
        self.stations = stations
        self.obstacles = obstacles
        self.circuits = circuits
    }
}
