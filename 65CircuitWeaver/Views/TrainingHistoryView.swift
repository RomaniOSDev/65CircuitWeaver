//
//  TrainingHistoryView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import SwiftData

struct TrainingHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessionsData: [TrainingSessionData]
    
    @State private var selectedSession: TrainingSession?
    @State private var showingStats = true
    
    private var sessions: [TrainingSession] {
        sessionsData.compactMap { $0.toTrainingSession() }
    }
    
    private var statistics: TrainingStatistics {
        TrainingStatistics.calculate(from: sessions)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Statistics Overview
                        if showingStats {
                            StatisticsOverviewCard(statistics: statistics)
                        }
                        
                        // Sessions List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Training Sessions")
                                .font(.headline)
                                .foregroundColor(.cwStation)
                                .padding(.horizontal)
                            
                            if sessions.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.system(size: 50))
                                        .foregroundColor(.cwStation.opacity(0.5))
                                    Text("No training sessions yet")
                                        .font(.headline)
                                        .foregroundColor(.cwStation.opacity(0.7))
                                    Text("Complete a circuit to see your history here")
                                        .font(.subheadline)
                                        .foregroundColor(.cwStation.opacity(0.5))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(sessions.sorted { $0.startDate > $1.startDate }) { session in
                                    SessionCard(session: session) {
                                        selectedSession = session
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Training History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingStats.toggle()
                    }) {
                        Image(systemName: showingStats ? "chart.bar.fill" : "chart.bar")
                            .foregroundColor(.cwActiveFlow)
                    }
                }
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
    }
}

struct StatisticsOverviewCard: View {
    let statistics: TrainingStatistics
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.cwStation)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Main stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Total Sessions",
                    value: "\(statistics.totalSessions)",
                    icon: "figure.run",
                    color: .cwActiveFlow
                )
                
                StatCard(
                    title: "Completed",
                    value: "\(statistics.completedSessions)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Total Rounds",
                    value: "\(statistics.totalRounds)",
                    icon: "arrow.triangle.2.circlepath",
                    color: .cwActiveFlow
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(statistics.currentStreak) days",
                    icon: "flame.fill",
                    color: .orange
                )
            }
            
            // Time stats
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Time")
                        .font(.caption)
                        .foregroundColor(.cwStation.opacity(0.7))
                    Text(formatTime(statistics.totalDuration))
                        .font(.title3)
                        .foregroundColor(.cwActiveFlow)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Average Duration")
                        .font(.caption)
                        .foregroundColor(.cwStation.opacity(0.7))
                    Text(formatTime(statistics.averageDuration))
                        .font(.title3)
                        .foregroundColor(.cwActiveFlow)
                }
            }
            
            if let favorite = statistics.favoriteCircuit {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Favorite Circuit:")
                        .font(.subheadline)
                        .foregroundColor(.cwStation.opacity(0.7))
                    Text(favorite)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.cwStation)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cwStation)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.cwStation.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [Color.cwBackground, Color.cwBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct SessionCard: View {
    let session: TrainingSession
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.circuitName)
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        Text(session.spaceName)
                            .font(.subheadline)
                            .foregroundColor(.cwStation.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if session.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                }
                
                HStack {
                    Label("\(session.completedRounds)/\(session.totalRounds) rounds", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundColor(.cwStation.opacity(0.7))
                    
                    Spacer()
                    
                    if let duration = session.duration {
                        Label(formatTime(duration), systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.cwStation.opacity(0.7))
                    }
                }
                
                Text(session.startDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.cwStation.opacity(0.5))
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
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

struct SessionDetailView: View {
    let session: TrainingSession
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(session.circuitName)
                            .font(.title)
                            .foregroundColor(.cwStation)
                        
                        Text(session.spaceName)
                            .font(.subheadline)
                            .foregroundColor(.cwStation.opacity(0.7))
                        
                        if let duration = session.duration {
                            Label(formatTime(duration), systemImage: "clock")
                                .font(.headline)
                                .foregroundColor(.cwActiveFlow)
                        }
                        
                        Text(session.startDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.cwStation.opacity(0.5))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress")
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        HStack {
                            Text("\(session.completedRounds) / \(session.totalRounds) rounds")
                                .font(.subheadline)
                                .foregroundColor(.cwStation)
                            
                            Spacer()
                            
                            if session.isCompleted {
                                Text("Completed")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        ProgressView(value: min(Double(session.completedRounds), Double(session.totalRounds)), total: Double(session.totalRounds))
                            .tint(.cwActiveFlow)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    if let notes = session.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(.cwStation)
                            
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.cwStation.opacity(0.8))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.cwBackground)
            .navigationTitle("Session Details")
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
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// SwiftData model for TrainingSession
@Model
final class TrainingSessionData {
    @Attribute(.unique) var id: UUID
    var circuitId: UUID
    var circuitName: String
    var spaceId: UUID
    var spaceName: String
    var startDate: Date
    var endDate: Date?
    var completedRounds: Int
    var totalRounds: Int
    var stationTimesData: Data?
    var transitionTimesData: Data?
    var notes: String?
    var rating: Int?
    
    init(from session: TrainingSession) {
        self.id = session.id
        self.circuitId = session.circuitId
        self.circuitName = session.circuitName
        self.spaceId = session.spaceId
        self.spaceName = session.spaceName
        self.startDate = session.startDate
        self.endDate = session.endDate
        self.completedRounds = session.completedRounds
        self.totalRounds = session.totalRounds
        self.notes = session.notes
        self.rating = session.rating
        
        // Encode dictionaries to Data
        self.stationTimesData = try? JSONEncoder().encode(session.stationTimes)
        self.transitionTimesData = try? JSONEncoder().encode(session.transitionTimes)
    }
    
    func toTrainingSession() -> TrainingSession? {
        var session = TrainingSession(
            id: id,
            circuitId: circuitId,
            circuitName: circuitName,
            spaceId: spaceId,
            spaceName: spaceName,
            startDate: startDate,
            totalRounds: totalRounds
        )
        session.endDate = endDate
        session.completedRounds = completedRounds
        session.notes = notes
        session.rating = rating
        
        if let stationData = stationTimesData {
            session.stationTimes = (try? JSONDecoder().decode([UUID: TimeInterval].self, from: stationData)) ?? [:]
        }
        if let transitionData = transitionTimesData {
            session.transitionTimes = (try? JSONDecoder().decode([UUID: TimeInterval].self, from: transitionData)) ?? [:]
        }
        
        return session
    }
}

#Preview {
    TrainingHistoryView()
}
