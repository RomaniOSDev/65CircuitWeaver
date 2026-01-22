//
//  CircuitDataModel.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftData

@Model
final class TrainingSpaceData {
    @Attribute(.unique) var id: UUID
    var name: String
    var stationsData: Data?
    var obstaclesData: Data?
    var circuitsData: Data?
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, stations: [Station] = [], obstacles: [Obstacle]? = nil, circuits: [TrainingCircuit] = []) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.stationsData = try? JSONEncoder().encode(stations)
        self.obstaclesData = obstacles != nil ? try? JSONEncoder().encode(obstacles) : nil
        self.circuitsData = try? JSONEncoder().encode(circuits)
    }
    
    func toTrainingSpace() -> TrainingSpace? {
        guard let stationsData = stationsData else { return nil }
        
        let stations = try? JSONDecoder().decode([Station].self, from: stationsData)
        let obstacles = obstaclesData != nil ? try? JSONDecoder().decode([Obstacle]?.self, from: obstaclesData!) : nil
        let circuits: [TrainingCircuit] = {
            if let circuitsData = circuitsData {
                return (try? JSONDecoder().decode([TrainingCircuit].self, from: circuitsData)) ?? []
            }
            return []
        }()
        
        return TrainingSpace(
            id: id,
            name: name,
            stations: stations ?? [],
            obstacles: obstacles,
            circuits: circuits
        )
    }
    
    func update(from space: TrainingSpace) {
        self.name = space.name
        self.stationsData = try? JSONEncoder().encode(space.stations)
        self.obstaclesData = space.obstacles != nil ? try? JSONEncoder().encode(space.obstacles) : nil
        self.circuitsData = try? JSONEncoder().encode(space.circuits)
    }
}
