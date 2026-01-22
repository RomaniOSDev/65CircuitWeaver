//
//  TrainingProgramsView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct TrainingProgramsView: View {
    @State private var selectedProgram: TrainingProgram?
    @State private var selectedGoal: ProgramGoal?
    
    private var programs: [TrainingProgram] {
        let all = TrainingProgramLibrary.shared.programs
        if let goal = selectedGoal {
            return all.filter { $0.goals.contains(goal) }
        }
        return all
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Goal filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(
                                title: "All Goals",
                                isSelected: selectedGoal == nil
                            ) {
                                selectedGoal = nil
                            }
                            
                            ForEach(ProgramGoal.allCases, id: \.self) { goal in
                                FilterChip(
                                    title: goal.rawValue,
                                    isSelected: selectedGoal == goal
                                ) {
                                    selectedGoal = selectedGoal == goal ? nil : goal
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.white)
                    
                    // Programs list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(programs) { program in
                                ProgramCard(program: program) {
                                    selectedProgram = program
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Training Programs")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedProgram) { program in
                ProgramDetailView(program: program)
            }
        }
    }
}

struct ProgramCard: View {
    let program: TrainingProgram
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(program.name)
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        Text(program.description)
                            .font(.subheadline)
                            .foregroundColor(.cwStation.opacity(0.7))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(program.difficulty.rawValue)
                            .font(.caption)
                            .foregroundColor(program.difficulty.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(program.difficulty.color.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                // Goals
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(program.goals, id: \.self) { goal in
                            HStack(spacing: 4) {
                                Image(systemName: goal.icon)
                                    .font(.caption)
                                Text(goal.rawValue)
                                    .font(.caption2)
                            }
                            .foregroundColor(.cwStation.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.cwBackground)
                            .cornerRadius(6)
                        }
                    }
                }
                
                // Program info
                HStack {
                    Label("\(program.duration) weeks", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.cwStation.opacity(0.7))
                    
                    Spacer()
                    
                    Label("\(program.frequency)/week", systemImage: "repeat")
                        .font(.caption)
                        .foregroundColor(.cwStation.opacity(0.7))
                    
                    Spacer()
                    
                    Label("\(program.circuits.count) circuits", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundColor(.cwStation.opacity(0.7))
                }
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

struct ProgramExecutionData: Identifiable {
    let id = UUID()
    let circuit: TrainingCircuit
    let space: TrainingSpace
}

struct ProgramDetailView: View {
    let program: TrainingProgram
    @Environment(\.dismiss) var dismiss
    @State private var selectedWeek = 1
    @State private var executionData: ProgramExecutionData?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(program.name)
                            .font(.title)
                            .foregroundColor(.cwStation)
                        
                        Text(program.description)
                            .font(.body)
                            .foregroundColor(.cwStation.opacity(0.8))
                        
                        HStack {
                            Text(program.difficulty.rawValue)
                                .font(.subheadline)
                                .foregroundColor(program.difficulty.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(program.difficulty.color.opacity(0.2))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Label("\(program.duration) weeks", systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundColor(.cwStation.opacity(0.7))
                            
                            Label("\(program.frequency)/week", systemImage: "repeat")
                                .font(.subheadline)
                                .foregroundColor(.cwStation.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Goals
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Goals")
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(program.goals, id: \.self) { goal in
                                HStack {
                                    Image(systemName: goal.icon)
                                        .foregroundColor(.cwActiveFlow)
                                    Text(goal.rawValue)
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
                    
                    // Circuits by week
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Program Schedule")
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        ForEach(1...program.duration, id: \.self) { week in
                            WeekCard(
                                week: week,
                                circuits: program.circuits.filter { $0.week == week }
                            )
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Program Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start") {
                        startProgram()
                    }
                    .foregroundColor(.cwActiveFlow)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.cwStation)
                }
            }
            .fullScreenCover(item: $executionData) { data in
                CircuitExecutionView(circuit: data.circuit, space: data.space)
            }
        }
    }
    
    private func startProgram() {
        // Берем первый circuit из программы (для первой недели)
        guard let firstCircuit = program.circuits.first else {
            return
        }
        
        let template = firstCircuit.circuitTemplate
        
        // Проверяем, что есть станции
        guard !template.stations.isEmpty else {
            return
        }
        
        // Создаем временные станции из шаблона
        var stations: [Station] = []
        var stationExercises: [StationExercise] = []
        var connections: [CircuitConnection] = []
        
        // Располагаем станции в ряд для простоты
        for (index, templateStation) in template.stations.enumerated() {
            let position = CGPoint(
                x: Double(index) * 0.2 + 0.1,
                y: 0.5
            )
            let station = Station(
                type: templateStation.stationType,
                position: position
            )
            stations.append(station)
            
            // Создаем StationExercise
            let exercise = StationExercise(
                stationId: station.id,
                exerciseName: templateStation.exerciseName,
                reps: templateStation.reps,
                time: templateStation.time,
                restAfter: templateStation.restAfter
            )
            stationExercises.append(exercise)
            
            // Создаем connection между станциями
            if index > 0 {
                let connection = CircuitConnection(
                    fromStationId: stations[index - 1].id,
                    toStationId: station.id,
                    estimatedTransitionTime: 30.0
                )
                connections.append(connection)
            }
        }
        
        // Создаем connection от последней станции к первой для замыкания круга
        if stations.count > 1 {
            let finalConnection = CircuitConnection(
                fromStationId: stations.last!.id,
                toStationId: stations.first!.id,
                estimatedTransitionTime: 30.0
            )
            connections.append(finalConnection)
        }
        
        // Создаем circuit из шаблона
        let circuit = TrainingCircuit(
            name: template.name,
            stations: stationExercises,
            connections: connections,
            rounds: template.rounds
        )
        
        // Создаем временное пространство
        let space = TrainingSpace(
            name: "\(program.name) - Week \(firstCircuit.week)",
            stations: stations,
            obstacles: nil,
            circuits: [circuit]
        )
        
        // Создаем объект с данными для выполнения
        let data = ProgramExecutionData(circuit: circuit, space: space)
        
        // Устанавливаем данные синхронно
        executionData = data
    }
}

struct WeekCard: View {
    let week: Int
    let circuits: [ProgramCircuit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Week \(week)")
                .font(.headline)
                .foregroundColor(.cwStation)
            
            ForEach(circuits) { programCircuit in
                VStack(alignment: .leading, spacing: 8) {
                    Text(programCircuit.circuitTemplate.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.cwStation)
                    
                    HStack {
                        Label("\(programCircuit.circuitTemplate.rounds) rounds", systemImage: "arrow.triangle.2.circlepath")
                            .font(.caption)
                            .foregroundColor(.cwStation.opacity(0.7))
                        
                        Spacer()
                        
                        if programCircuit.progression != .none {
                            Label(programCircuit.progression.rawValue, systemImage: "arrow.up")
                                .font(.caption)
                                .foregroundColor(.cwActiveFlow)
                        }
                    }
                    
                    // Stations preview
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(programCircuit.circuitTemplate.stations.prefix(4)) { station in
                                HStack(spacing: 4) {
                                    Image(systemName: station.stationType.iconName)
                                        .font(.caption2)
                                    Text(station.exerciseName)
                                        .font(.caption2)
                                }
                                .foregroundColor(.cwStation.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.cwBackground)
                                .cornerRadius(6)
                            }
                            
                            if programCircuit.circuitTemplate.stations.count > 4 {
                                Text("+\(programCircuit.circuitTemplate.stations.count - 4)")
                                    .font(.caption2)
                                    .foregroundColor(.cwStation.opacity(0.5))
                            }
                        }
                    }
                }
                .padding()
                .background(Color.cwBackground)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    TrainingProgramsView()
}
