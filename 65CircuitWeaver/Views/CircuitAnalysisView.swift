//
//  CircuitAnalysisView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct CircuitAnalysisView: View {
    let circuit: TrainingCircuit
    let space: TrainingSpace
    let executionData: ExecutionData
    
    struct ExecutionData {
        var stationTimes: [UUID: TimeInterval] = [:]
        var transitionTimes: [UUID: TimeInterval] = [:]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Overview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Performance Overview")
                                .font(.headline)
                                .foregroundColor(.cwStation)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total Time")
                                        .font(.caption)
                                        .foregroundColor(.cwStation.opacity(0.7))
                                    Text("45:30")
                                        .font(.title2)
                                        .foregroundColor(.cwActiveFlow)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Average per Round")
                                        .font(.caption)
                                        .foregroundColor(.cwStation.opacity(0.7))
                                    Text("15:10")
                                        .font(.title2)
                                        .foregroundColor(.cwActiveFlow)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Station performance
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Station Performance")
                                .font(.headline)
                                .foregroundColor(.cwStation)
                            
                            ForEach(circuit.stations) { exercise in
                                if let station = space.stations.first(where: { $0.id == exercise.stationId }) {
                                    StationPerformanceRow(
                                        station: station,
                                        exercise: exercise,
                                        actualTime: executionData.stationTimes[station.id] ?? 0,
                                        plannedTime: exercise.time ?? 60
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Transition analysis
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Transition Analysis")
                                .font(.headline)
                                .foregroundColor(.cwStation)
                            
                            ForEach(circuit.connections) { connection in
                                if let fromStation = space.stations.first(where: { $0.id == connection.fromStationId }),
                                   let toStation = space.stations.first(where: { $0.id == connection.toStationId }) {
                                    
                                    TransitionAnalysisRow(
                                        fromStation: fromStation,
                                        toStation: toStation,
                                        estimatedTime: connection.estimatedTransitionTime,
                                        actualTime: executionData.transitionTimes[connection.id] ?? connection.estimatedTransitionTime
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Recommendations
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommendations")
                                .font(.headline)
                                .foregroundColor(.cwStation)
                            
                            RecommendationCard(
                                title: "Optimize Transition",
                                message: "Transition between stations 3 and 4 took 40% longer than estimated. Consider changing the order.",
                                icon: "arrow.triangle.2.circlepath"
                            )
                            
                            RecommendationCard(
                                title: "Reduce Rest Time",
                                message: "You completed exercises faster than planned. Consider reducing rest time to improve efficiency.",
                                icon: "clock.arrow.circlepath"
                            )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Circuit Analysis")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StationPerformanceRow: View {
    let station: Station
    let exercise: StationExercise
    let actualTime: TimeInterval
    let plannedTime: TimeInterval
    
    private var performanceColor: Color {
        let ratio = actualTime / plannedTime
        if ratio < 0.9 {
            return .cwActiveFlow // Faster than planned
        } else if ratio > 1.1 {
            return .cwStation // Slower than planned
        } else {
            return .gray // On target
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: station.iconName)
                .foregroundColor(.cwActiveFlow)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exerciseName)
                    .font(.subheadline)
                    .foregroundColor(.cwStation)
                
                HStack {
                    Text("Planned: \(Int(plannedTime))s")
                        .font(.caption)
                        .foregroundColor(.cwStation.opacity(0.7))
                    
                    Text("•")
                        .foregroundColor(.cwStation.opacity(0.7))
                    
                    Text("Actual: \(Int(actualTime))s")
                        .font(.caption)
                        .foregroundColor(performanceColor)
                }
            }
            
            Spacer()
            
            Circle()
                .fill(performanceColor)
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 8)
    }
}

struct TransitionAnalysisRow: View {
    let fromStation: Station
    let toStation: Station
    let estimatedTime: TimeInterval
    let actualTime: TimeInterval
    
    private var performanceColor: Color {
        let ratio = actualTime / estimatedTime
        if ratio < 0.9 {
            return .cwActiveFlow
        } else if ratio > 1.1 {
            return .cwStation
        } else {
            return .gray
        }
    }
    
    private var percentageDifference: Int {
        let diff = ((actualTime - estimatedTime) / estimatedTime) * 100
        return Int(diff)
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: fromStation.iconName)
                    .foregroundColor(.cwStation)
                    .frame(width: 20)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.cwStation.opacity(0.5))
                    .font(.caption)
                
                Image(systemName: toStation.iconName)
                    .foregroundColor(.cwStation)
                    .frame(width: 20)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Transition Time")
                    .font(.subheadline)
                    .foregroundColor(.cwStation)
                
                HStack {
                    Text("Est: \(Int(estimatedTime))s")
                        .font(.caption)
                        .foregroundColor(.cwStation.opacity(0.7))
                    
                    Text("•")
                        .foregroundColor(.cwStation.opacity(0.7))
                    
                    Text("Act: \(Int(actualTime))s")
                        .font(.caption)
                        .foregroundColor(performanceColor)
                    
                    if abs(percentageDifference) > 5 {
                        Text("(\(percentageDifference > 0 ? "+" : "")\(percentageDifference)%)")
                            .font(.caption)
                            .foregroundColor(performanceColor)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct RecommendationCard: View {
    let title: String
    let message: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.cwActiveFlow)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cwStation)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.cwStation.opacity(0.7))
            }
        }
        .padding()
        .background(Color.cwBackground)
        .cornerRadius(8)
    }
}

#Preview {
    CircuitAnalysisView(
        circuit: TrainingCircuit(
            name: "Test Circuit",
            stations: [
                StationExercise(stationId: UUID(), exerciseName: "Kettlebell Swings", time: 60, restAfter: 30),
                StationExercise(stationId: UUID(), exerciseName: "Pull-ups", time: 45, restAfter: 30)
            ],
            connections: [
                CircuitConnection(fromStationId: UUID(), toStationId: UUID(), estimatedTransitionTime: 30)
            ],
            rounds: 3
        ),
        space: TrainingSpace(name: "Test", stations: [
            Station(type: .kettlebell, position: CGPoint(x: 0.3, y: 0.3)),
            Station(type: .pullUpBar, position: CGPoint(x: 0.7, y: 0.7))
        ]),
        executionData: CircuitAnalysisView.ExecutionData()
    )
}
