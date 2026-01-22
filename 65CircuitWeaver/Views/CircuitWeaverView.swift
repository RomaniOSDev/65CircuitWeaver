//
//  CircuitWeaverView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct CircuitWeaverView: View {
    @StateObject private var viewModel: CircuitWeaverViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingExerciseSheet = false
    @State private var selectedStationForExercise: Station?
    @State private var showingExecution = false
    @State private var showingAnalysis = false
    @State private var lineAnimations: [UUID: Double] = [:]
    
    init(space: TrainingSpace) {
        _viewModel = StateObject(wrappedValue: CircuitWeaverViewModel(space: space))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ZStack {
                        // Obstacles
                        if let obstacles = viewModel.currentSpace.obstacles {
                            ForEach(obstacles) { obstacle in
                                Path { path in
                                    if let first = obstacle.path.first {
                                        path.move(to: CGPoint(
                                            x: first.x * geometry.size.width,
                                            y: first.y * geometry.size.height
                                        ))
                                        for point in obstacle.path.dropFirst() {
                                            path.addLine(to: CGPoint(
                                                x: point.x * geometry.size.width,
                                                y: point.y * geometry.size.height
                                            ))
                                        }
                                    }
                                }
                                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            }
                        }
                        
                        // Connections (lines between stations)
                        ForEach(viewModel.connections) { connection in
                            if let fromStation = viewModel.currentSpace.stations.first(where: { $0.id == connection.fromStationId }),
                               let toStation = viewModel.currentSpace.stations.first(where: { $0.id == connection.toStationId }) {
                                
                                let lineCompletion = lineAnimations[connection.id] ?? 0.0
                                
                                Path { path in
                                    let fromPoint = CGPoint(
                                        x: fromStation.position.x * geometry.size.width,
                                        y: fromStation.position.y * geometry.size.height
                                    )
                                    let toPoint = CGPoint(
                                        x: toStation.position.x * geometry.size.width,
                                        y: toStation.position.y * geometry.size.height
                                    )
                                    
                                    path.move(to: fromPoint)
                                    path.addLine(to: toPoint)
                                }
                                .trim(from: 0, to: lineCompletion)
                                .stroke(
                                    Color.cwActiveFlow,
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                                )
                                .overlay(
                                    Group {
                                        if lineCompletion > 0.5 {
                                            Text("\(Int(connection.estimatedTransitionTime))s")
                                                .font(.caption2)
                                                .foregroundColor(.cwActiveFlow)
                                                .padding(4)
                                                .background(Color.white)
                                                .cornerRadius(4)
                                                .position(
                                                    x: (fromStation.position.x + toStation.position.x) / 2 * geometry.size.width,
                                                    y: (fromStation.position.y + toStation.position.y) / 2 * geometry.size.height
                                                )
                                                .opacity(lineCompletion)
                                        }
                                    }
                                )
                            }
                        }
                        
                        // Stations
                        ForEach(viewModel.currentSpace.stations) { station in
                            let isSelected = viewModel.selectedStationId == station.id
                            
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? Color.cwActiveFlow : Color.cwStation)
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: station.iconName)
                                        .foregroundColor(.white)
                                        .font(.system(size: 24))
                                }
                                
                                if let exercise = viewModel.currentCircuit?.stations.first(where: { $0.stationId == station.id }) {
                                    Text(exercise.exerciseName)
                                        .font(.caption2)
                                        .foregroundColor(.cwStation)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.white)
                                        .cornerRadius(4)
                                }
                            }
                            .position(
                                x: station.position.x * geometry.size.width,
                                y: station.position.y * geometry.size.height
                            )
                            .onTapGesture {
                                viewModel.selectStation(station.id)
                                selectedStationForExercise = station
                                showingExerciseSheet = true
                            }
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    
                    // Control panel
                    VStack(spacing: 16) {
                        if !viewModel.connections.isEmpty {
                            HStack(spacing: 12) {
                                Button(action: {
                                    let circuit = viewModel.createCircuitFromConnections()
                                    CircuitDataManager.shared.saveSpace(viewModel.currentSpace, to: modelContext)
                                }) {
                                    Text("Create Circuit")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.cwActiveFlow)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    viewModel.resetSelection()
                                }) {
                                    Text("Reset")
                                        .font(.headline)
                                        .foregroundColor(.cwActiveFlow)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.cwActiveFlow, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        
                        if let circuit = viewModel.currentCircuit {
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Current Circuit: \(circuit.name)")
                                        .font(.headline)
                                        .foregroundColor(.cwStation)
                                    
                                    Text("\(circuit.stations.count) stations • \(circuit.rounds) rounds")
                                        .font(.caption)
                                        .foregroundColor(.cwStation.opacity(0.7))
                                }
                                
                                HStack(spacing: 12) {
                                    Button(action: {
                                        showingExecution = true
                                    }) {
                                        Text("Start")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.cwActiveFlow)
                                            .cornerRadius(12)
                                    }
                                    
                                    Button(action: {
                                        showingAnalysis = true
                                    }) {
                                        Text("Analyze")
                                            .font(.headline)
                                            .foregroundColor(.cwActiveFlow)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.cwActiveFlow, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
            }
            .navigationTitle("Circuit Weaver")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewModel.connections.count) { newCount in
                // Animate new connections
                for connection in viewModel.connections {
                    if lineAnimations[connection.id] == nil {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            lineAnimations[connection.id] = 1.0
                        }
                    }
                }
            }
            .onAppear {
                // Animate existing connections
                for connection in viewModel.connections {
                    withAnimation(.easeInOut(duration: 0.5).delay(0.1)) {
                        lineAnimations[connection.id] = 1.0
                    }
                }
            }
            .sheet(isPresented: $showingExerciseSheet) {
                if let station = selectedStationForExercise {
                    ExerciseConfigurationSheet(
                        station: station,
                        exercise: viewModel.currentCircuit?.stations.first(where: { $0.stationId == station.id }),
                        onSave: { exercise in
                            // Update exercise in circuit
                            if var circuit = viewModel.currentCircuit {
                                if let index = circuit.stations.firstIndex(where: { $0.stationId == station.id }) {
                                    circuit.stations[index] = exercise
                                } else {
                                    circuit.stations.append(exercise)
                                }
                                viewModel.currentCircuit = circuit
                            }
                            showingExerciseSheet = false
                        }
                    )
                }
            }
            .fullScreenCover(isPresented: $showingExecution) {
                if let circuit = viewModel.currentCircuit {
                    CircuitExecutionView(circuit: circuit, space: viewModel.currentSpace)
                }
            }
            .sheet(isPresented: $showingAnalysis) {
                if let circuit = viewModel.currentCircuit {
                    CircuitAnalysisView(
                        circuit: circuit,
                        space: viewModel.currentSpace,
                        executionData: CircuitAnalysisView.ExecutionData()
                    )
                }
            }
        }
    }
}

struct ExerciseConfigurationSheet: View {
    let station: Station
    let exercise: StationExercise?
    let onSave: (StationExercise) -> Void
    
    @State private var exerciseName: String = ""
    @State private var reps: String = ""
    @State private var time: String = ""
    @State private var restAfter: Double = 60
    @State private var showingExerciseLibrary = false
    @State private var selectedLibraryExercise: Exercise?
    
    @Environment(\.dismiss) var dismiss
    
    private var availableExercises: [Exercise] {
        ExerciseLibrary.shared.exercises(for: station.type)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Station")) {
                    HStack {
                        Image(systemName: station.iconName)
                            .foregroundColor(.cwActiveFlow)
                        Text(station.type.displayName)
                    }
                }
                
                Section(header: Text("Exercise Library")) {
                    Button(action: {
                        showingExerciseLibrary = true
                    }) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.cwActiveFlow)
                            Text("Browse Exercises")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if !availableExercises.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(availableExercises.prefix(5)) { libExercise in
                                    Button(action: {
                                        selectedLibraryExercise = libExercise
                                        applyExercise(libExercise)
                                    }) {
                                        VStack(spacing: 4) {
                                            Text(libExercise.name)
                                                .font(.caption)
                                                .foregroundColor(.cwStation)
                                                .lineLimit(1)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedLibraryExercise?.id == libExercise.id ? Color.cwActiveFlow.opacity(0.2) : Color.cwBackground)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Exercise")) {
                    TextField("Exercise Name", text: $exerciseName)
                    
                    HStack {
                        Text("Reps")
                        Spacer()
                        TextField("0", text: $reps)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Time (seconds)")
                        Spacer()
                        TextField("0", text: $time)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Rest After")) {
                    VStack(alignment: .leading) {
                        Text("\(Int(restAfter)) seconds")
                        Slider(value: $restAfter, in: 0...300, step: 5)
                    }
                }
            }
            .navigationTitle("Configure Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let exercise = StationExercise(
                            stationId: station.id,
                            exerciseName: exerciseName.isEmpty ? "Exercise" : exerciseName,
                            reps: Int(reps),
                            time: Double(time),
                            restAfter: restAfter
                        )
                        onSave(exercise)
                        dismiss()
                    }
                    .foregroundColor(.cwActiveFlow)
                }
            }
            .onAppear {
                if let exercise = exercise {
                    exerciseName = exercise.exerciseName
                    reps = exercise.reps.map { String($0) } ?? ""
                    time = exercise.time.map { String(Int($0)) } ?? ""
                    restAfter = exercise.restAfter
                }
            }
            .sheet(isPresented: $showingExerciseLibrary) {
                ExerciseLibraryView()
            }
        }
    }
    
    private func applyExercise(_ exercise: Exercise) {
        exerciseName = exercise.name
        reps = exercise.defaultReps.map { String($0) } ?? ""
        time = exercise.defaultTime.map { String(Int($0)) } ?? ""
        restAfter = exercise.defaultRest
    }
}

#Preview {
    CircuitWeaverView(space: TrainingSpace(name: "Test", stations: [
        Station(type: .kettlebell, position: CGPoint(x: 0.3, y: 0.3)),
        Station(type: .mat, position: CGPoint(x: 0.7, y: 0.7))
    ]))
}
