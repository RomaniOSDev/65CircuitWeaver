//
//  HomeView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessionsData: [TrainingSessionData]
    @Query private var spacesData: [TrainingSpaceData]
    
    @State private var showingSpaceLibrary = false
    @State private var showingExerciseLibrary = false
    @State private var showingPrograms = false
    @State private var showingHistory = false
    
    private var sessions: [TrainingSession] {
        sessionsData.compactMap { $0.toTrainingSession() }
    }
    
    private var spaces: [TrainingSpace] {
        spacesData.compactMap { $0.toTrainingSpace() }
    }
    
    private var statistics: TrainingStatistics {
        TrainingStatistics.calculate(from: sessions)
    }
    
    private var recentSessions: [TrainingSession] {
        sessions.sorted { $0.startDate > $1.startDate }.prefix(3).map { $0 }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with greeting
                        VStack(alignment: .leading, spacing: 8) {
                            Text(greeting)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.cwStation)
                            
                            Text("Ready to weave your circuit?")
                                .font(.subheadline)
                                .foregroundColor(.cwStation.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Quick stats cards
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                HomeStatCard(
                                    title: "Total Sessions",
                                    value: "\(statistics.totalSessions)",
                                    icon: "figure.run",
                                    color: .cwActiveFlow
                                )
                                
                                HomeStatCard(
                                    title: "Current Streak",
                                    value: "\(statistics.currentStreak)",
                                    subtitle: "days",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                                
                                HomeStatCard(
                                    title: "Spaces",
                                    value: "\(spaces.count)",
                                    icon: "mappin.circle.fill",
                                    color: .blue
                                )
                                
                                HomeStatCard(
                                    title: "Total Time",
                                    value: formatTime(statistics.totalDuration),
                                    icon: "clock.fill",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Quick actions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Actions")
                                .font(.headline)
                                .foregroundColor(.cwStation)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                QuickActionCard(
                                    title: "Create Space",
                                    icon: "plus.circle.fill",
                                    color: .cwActiveFlow
                                ) {
                                    showingSpaceLibrary = true
                                }
                                
                                QuickActionCard(
                                    title: "Exercise Library",
                                    icon: "book.fill",
                                    color: .blue
                                ) {
                                    showingExerciseLibrary = true
                                }
                                
                                QuickActionCard(
                                    title: "Training Programs",
                                    icon: "list.bullet.rectangle",
                                    color: .green
                                ) {
                                    showingPrograms = true
                                }
                                
                                QuickActionCard(
                                    title: "View History",
                                    icon: "clock.fill",
                                    color: .orange
                                ) {
                                    showingHistory = true
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Recent sessions
                        if !recentSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Recent Sessions")
                                        .font(.headline)
                                        .foregroundColor(.cwStation)
                                    
                                    Spacer()
                                    
                                    Button("See All") {
                                        showingHistory = true
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.cwActiveFlow)
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    ForEach(recentSessions) { session in
                                        RecentSessionCard(session: session)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Spaces preview
                        if !spaces.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Your Spaces")
                                        .font(.headline)
                                        .foregroundColor(.cwStation)
                                    
                                    Spacer()
                                    
                                    Button("See All") {
                                        showingSpaceLibrary = true
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.cwActiveFlow)
                                }
                                .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(spaces.prefix(5)) { space in
                                            SpacePreviewCard(space: space)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Circuit Weaver")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingSpaceLibrary) {
                NavigationStack {
                    SpaceLibraryView()
                }
            }
            .sheet(isPresented: $showingExerciseLibrary) {
                NavigationStack {
                    ExerciseLibraryView()
                }
            }
            .sheet(isPresented: $showingPrograms) {
                NavigationStack {
                    TrainingProgramsView()
                }
            }
            .sheet(isPresented: $showingHistory) {
                NavigationStack {
                    TrainingHistoryView()
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h"
        }
        return "\(minutes)m"
    }
}

struct HomeStatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.cwStation)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.cwStation.opacity(0.7))
                    }
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.cwStation.opacity(0.7))
            }
        }
        .padding()
        .frame(width: 140)
        .background(
            LinearGradient(
                colors: [Color.white, Color.white.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cwStation)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                LinearGradient(
                    colors: [Color.white, Color.white.opacity(0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: color.opacity(0.25), radius: 15, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentSessionCard: View {
    let session: TrainingSession
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.cwActiveFlow.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "clock.fill")
                    .foregroundColor(session.isCompleted ? .green : .cwActiveFlow)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.circuitName)
                    .font(.headline)
                    .foregroundColor(.cwStation)
                
                Text(session.spaceName)
                    .font(.caption)
                    .foregroundColor(.cwStation.opacity(0.7))
                
                HStack(spacing: 8) {
                    Label("\(session.completedRounds)/\(session.totalRounds)", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption2)
                        .foregroundColor(.cwStation.opacity(0.7))
                    
                    if let duration = session.duration {
                        Label(formatTime(duration), systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.cwStation.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            Text(session.startDate, style: .relative)
                .font(.caption)
                .foregroundColor(.cwStation.opacity(0.5))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.white, Color.white.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cwActiveFlow.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.cwActiveFlow.opacity(0.15), radius: 10, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        return "\(minutes)m"
    }
}

struct SpacePreviewCard: View {
    let space: TrainingSpace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.cwActiveFlow)
                    .font(.title3)
                
                Spacer()
                
                Text("\(space.stations.count)")
                    .font(.caption)
                    .foregroundColor(.cwStation.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cwBackground)
                    .cornerRadius(8)
            }
            
            Text(space.name)
                .font(.headline)
                .foregroundColor(.cwStation)
                .lineLimit(2)
            
            Text("\(space.circuits.count) circuits")
                .font(.caption)
                .foregroundColor(.cwStation.opacity(0.7))
        }
        .padding()
        .frame(width: 160)
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
                .stroke(Color.cwActiveFlow.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.cwActiveFlow.opacity(0.2), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [TrainingSpaceData.self, TrainingSessionData.self])
}
