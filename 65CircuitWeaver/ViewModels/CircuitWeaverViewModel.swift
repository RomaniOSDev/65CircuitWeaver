//
//  CircuitWeaverViewModel.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI
import Combine

class CircuitWeaverViewModel: ObservableObject {
    @Published var currentSpace: TrainingSpace
    @Published var selectedStationId: UUID?
    @Published var currentCircuit: TrainingCircuit?
    @Published var connections: [CircuitConnection] = []
    
    init(space: TrainingSpace) {
        self.currentSpace = space
    }
    
    func addStation(type: StationType, at position: CGPoint) {
        let newStation = Station(type: type, position: position)
        currentSpace.stations.append(newStation)
    }
    
    func selectStation(_ stationId: UUID) {
        guard let lastSelected = selectedStationId else {
            selectedStationId = stationId
            return
        }
        
        if lastSelected != stationId {
            guard let fromStation = currentSpace.stations.first(where: { $0.id == lastSelected }),
                  let toStation = currentSpace.stations.first(where: { $0.id == stationId }) else {
                selectedStationId = stationId
                return
            }
            
            let distance = hypot(
                toStation.position.x - fromStation.position.x,
                toStation.position.y - fromStation.position.y
            )
            
            let transitionTime = CircuitEngine.estimateTransitionTime(
                from: fromStation,
                to: toStation,
                distance: distance
            )
            
            let connection = CircuitConnection(
                fromStationId: lastSelected,
                toStationId: stationId,
                estimatedTransitionTime: transitionTime
            )
            
            connections.append(connection)
        }
        
        selectedStationId = stationId
    }
    
    func createCircuitFromConnections() -> TrainingCircuit {
        guard !connections.isEmpty else {
            return TrainingCircuit(
                name: "New Circuit",
                stations: [],
                connections: [],
                rounds: 3
            )
        }
        
        var stationSequence: [Station] = []
        var visited: Set<UUID> = []
        
        if let firstConnection = connections.first {
            if let fromStation = currentSpace.stations.first(where: { $0.id == firstConnection.fromStationId }) {
                stationSequence.append(fromStation)
                visited.insert(fromStation.id)
            }
            
            var currentId = firstConnection.fromStationId
            while let connection = connections.first(where: { $0.fromStationId == currentId }) {
                if let toStation = currentSpace.stations.first(where: { $0.id == connection.toStationId }),
                   !visited.contains(toStation.id) {
                    stationSequence.append(toStation)
                    visited.insert(toStation.id)
                    currentId = connection.toStationId
                } else {
                    break
                }
            }
        }
        
        let circuit = TrainingCircuit(
            name: "New Circuit",
            stations: stationSequence.map { station in
                StationExercise(
                    stationId: station.id,
                    exerciseName: "Exercise",
                    restAfter: 60
                )
            },
            connections: connections,
            rounds: 3
        )
        
        currentSpace.circuits.append(circuit)
        currentCircuit = circuit
        return circuit
    }
    
    func resetSelection() {
        selectedStationId = nil
        connections = []
    }
}
