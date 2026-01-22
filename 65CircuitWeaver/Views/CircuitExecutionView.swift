//
//  CircuitExecutionView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import UserNotifications
import Combine
import SwiftData

struct CircuitExecutionView: View {
    @StateObject private var viewModel: CircuitExecutionViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var isPulsing = false
    
    init(circuit: TrainingCircuit, space: TrainingSpace) {
        _viewModel = StateObject(wrappedValue: CircuitExecutionViewModel(circuit: circuit, space: space))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ZStack {
                        // Проверка на пустые данные
                        if viewModel.circuit.stations.isEmpty || viewModel.space.stations.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                                
                                Text("No stations available")
                                    .font(.headline)
                                    .foregroundColor(.cwStation)
                                
                                Text("This circuit has no exercises configured")
                                    .font(.subheadline)
                                    .foregroundColor(.cwStation.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        } else {
                            // All stations (dimmed)
                            ForEach(viewModel.space.stations) { station in
                            let isCurrent = viewModel.currentStationId == station.id
                            let isNext = viewModel.nextStationId == station.id
                            
                            VStack(spacing: 4) {
                                ZStack {
                                    // Pulsing ring for current station
                                    if isCurrent {
                                        Circle()
                                            .stroke(Color.cwActiveFlow.opacity(0.6), lineWidth: 3)
                                            .frame(width: 80, height: 80)
                                            .scaleEffect(pulseScale)
                                            .opacity(isPulsing ? 0.0 : 1.0)
                                    }
                                    
                                    Circle()
                                        .fill(isCurrent ? Color.cwActiveFlow : (isNext ? Color.cwStation.opacity(0.5) : Color.cwStation.opacity(0.3)))
                                        .frame(width: isCurrent ? 60 : 40, height: isCurrent ? 60 : 40)
                                        .shadow(color: isCurrent ? Color.cwActiveFlow.opacity(0.5) : Color.clear, radius: 15)
                                    
                                    Image(systemName: station.iconName)
                                        .foregroundColor(.white)
                                        .font(.system(size: isCurrent ? 28 : 20))
                                }
                                
                                if isCurrent, let exercise = viewModel.currentExercise {
                                    Text(exercise.exerciseName)
                                        .font(.caption)
                                        .foregroundColor(.cwStation)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color.white)
                                        .cornerRadius(6)
                                }
                            }
                            .position(
                                x: station.position.x * geometry.size.width,
                                y: station.position.y * geometry.size.height
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCurrent)
                            }
                            
                            // Connection to next station
                            if let currentStation = viewModel.space.stations.first(where: { $0.id == viewModel.currentStationId }),
                               let nextStation = viewModel.space.stations.first(where: { $0.id == viewModel.nextStationId }) {
                            
                            Path { path in
                                let fromPoint = CGPoint(
                                    x: currentStation.position.x * geometry.size.width,
                                    y: currentStation.position.y * geometry.size.height
                                )
                                let toPoint = CGPoint(
                                    x: nextStation.position.x * geometry.size.width,
                                    y: nextStation.position.y * geometry.size.height
                                )
                                
                                path.move(to: fromPoint)
                                path.addLine(to: toPoint)
                            }
                            .stroke(Color.cwStation.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            
                            // Arrow
                            let angle = atan2(
                                nextStation.position.y - currentStation.position.y,
                                nextStation.position.x - currentStation.position.x
                            )
                            let midPoint = CGPoint(
                                x: (currentStation.position.x + nextStation.position.x) / 2 * geometry.size.width,
                                y: (currentStation.position.y + nextStation.position.y) / 2 * geometry.size.height
                            )
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.cwStation)
                                .font(.title2)
                                .position(midPoint)
                                .rotationEffect(.radians(Double(angle)))
                            }
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    
                    // Timer and controls
                    VStack(spacing: 20) {
                        // Timer
                        VStack(spacing: 8) {
                            Text(viewModel.isResting ? "Rest" : "Exercise")
                                .font(.headline)
                                .foregroundColor(.cwStation)
                            
                            Text(timeString(from: viewModel.timeRemaining))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.cwActiveFlow)
                                .monospacedDigit()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // Current exercise info
                        if let exercise = viewModel.currentExercise {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(exercise.exerciseName)
                                    .font(.headline)
                                    .foregroundColor(.cwStation)
                                
                                if let reps = exercise.reps {
                                    Text("\(reps) reps")
                                        .font(.subheadline)
                                        .foregroundColor(.cwStation.opacity(0.7))
                                }
                                
                                if let time = exercise.time {
                                    Text("\(Int(time)) seconds")
                                        .font(.subheadline)
                                        .foregroundColor(.cwStation.opacity(0.7))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Controls
                        HStack(spacing: 12) {
                            Button(action: {
                                viewModel.togglePause()
                            }) {
                                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.cwStation)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                viewModel.completeCurrent()
                            }) {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.cwActiveFlow)
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Progress
                        VStack(spacing: 4) {
                            Text("Round \(viewModel.currentRound) of \(viewModel.circuit.rounds)")
                                .font(.caption)
                                .foregroundColor(.cwStation.opacity(0.7))
                            
                            ProgressView(value: min(Double(viewModel.currentRound), Double(viewModel.circuit.rounds)), total: Double(viewModel.circuit.rounds))
                                .tint(.cwActiveFlow)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                }
            }
            .navigationTitle("Circuit Execution")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                requestNotificationPermission()
                startPulsingAnimation()
            }
            .onChange(of: viewModel.currentStationId) { _ in
                // Trigger notification on station change
                sendStationChangeNotification()
                // Restart pulsing animation
                startPulsingAnimation()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Stop") {
                        viewModel.stop()
                        // Save session to history
                        if let session = viewModel.createSession() {
                            let sessionData = TrainingSessionData(from: session)
                            modelContext.insert(sessionData)
                            try? modelContext.save()
                        }
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func startPulsingAnimation() {
        isPulsing = true
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
            pulseScale = 1.5
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    private func sendStationChangeNotification() {
        guard let exercise = viewModel.currentExercise else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Next Station"
        content.body = exercise.exerciseName
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

class CircuitExecutionViewModel: ObservableObject {
    @Published var circuit: TrainingCircuit
    @Published var space: TrainingSpace
    @Published var currentStationIndex: Int = 0
    @Published var currentRound: Int = 1
    @Published var timeRemaining: TimeInterval = 0
    @Published var isResting: Bool = false
    @Published var isPaused: Bool = false
    
    private var timer: Timer?
    private var sessionStartDate: Date
    var stationTimes: [UUID: TimeInterval] = [:]
    var transitionTimes: [UUID: TimeInterval] = [:]
    private var currentStationStartTime: Date?
    
    var currentStationId: UUID? {
        guard currentStationIndex < circuit.stations.count else { return nil }
        return circuit.stations[currentStationIndex].stationId
    }
    
    var nextStationId: UUID? {
        let nextIndex = currentStationIndex + 1
        if nextIndex < circuit.stations.count {
            return circuit.stations[nextIndex].stationId
        } else if currentRound < circuit.rounds {
            return circuit.stations.first?.stationId
        }
        return nil
    }
    
    var currentExercise: StationExercise? {
        guard currentStationIndex < circuit.stations.count else { return nil }
        return circuit.stations[currentStationIndex]
    }
    
    init(circuit: TrainingCircuit, space: TrainingSpace) {
        self.circuit = circuit
        self.space = space
        self.sessionStartDate = Date()
        
        // Проверяем, что circuit имеет станции
        guard !circuit.stations.isEmpty else {
            return
        }
        
        startExercise()
    }
    
    func startExercise() {
        guard let exercise = currentExercise else { return }
        
        // Record transition time if moving from previous station
        if let previousStationId = currentStationId,
           let startTime = currentStationStartTime {
            let transitionTime = Date().timeIntervalSince(startTime)
            if let connection = circuit.connections.first(where: { $0.toStationId == previousStationId }) {
                transitionTimes[connection.id] = transitionTime
            }
        }
        
        isResting = false
        currentStationStartTime = Date()
        
        if let time = exercise.time {
            timeRemaining = time
        } else {
            timeRemaining = 60 // Default
        }
        
        startTimer()
    }
    
    func startRest() {
        guard let exercise = currentExercise else { return }
        
        isResting = true
        timeRemaining = exercise.restAfter
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                if self.isResting {
                    self.completeCurrent()
                } else {
                    self.startRest()
                }
            }
        }
    }
    
    func completeCurrent() {
        timer?.invalidate()
        
        // Record station time
        if let stationId = currentStationId,
           let startTime = currentStationStartTime {
            let stationTime = Date().timeIntervalSince(startTime)
            stationTimes[stationId] = stationTime
        }
        
        if isResting {
            // Move to next station
            currentStationIndex += 1
            
            if currentStationIndex >= circuit.stations.count {
                currentRound += 1
                if currentRound > circuit.rounds {
                    // Circuit complete
                    return
                }
                currentStationIndex = 0
            }
            
            startExercise()
        } else {
            startRest()
        }
    }
    
    func togglePause() {
        isPaused.toggle()
        if !isPaused {
            startTimer()
        } else {
            timer?.invalidate()
        }
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    func createSession() -> TrainingSession? {
        var session = TrainingSession(
            circuitId: circuit.id,
            circuitName: circuit.name,
            spaceId: space.id,
            spaceName: space.name,
            startDate: sessionStartDate,
            totalRounds: circuit.rounds
        )
        session.endDate = Date()
        session.completedRounds = currentRound - 1 // Subtract 1 because we increment before checking
        session.stationTimes = stationTimes
        session.transitionTimes = transitionTimes
        return session
    }
}

#Preview {
    CircuitExecutionView(
        circuit: TrainingCircuit(
            name: "Test Circuit",
            stations: [
                StationExercise(stationId: UUID(), exerciseName: "Kettlebell Swings", reps: 20, restAfter: 30),
                StationExercise(stationId: UUID(), exerciseName: "Pull-ups", reps: 10, restAfter: 30)
            ],
            connections: [],
            rounds: 3
        ),
        space: TrainingSpace(name: "Test", stations: [
            Station(type: .kettlebell, position: CGPoint(x: 0.3, y: 0.3)),
            Station(type: .pullUpBar, position: CGPoint(x: 0.7, y: 0.7))
        ])
    )
}
