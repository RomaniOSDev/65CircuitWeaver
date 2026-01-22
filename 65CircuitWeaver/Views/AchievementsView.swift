//
//  AchievementsView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import SwiftData

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager()
    @Environment(\.modelContext) private var modelContext
    
    @Query private var sessionsData: [TrainingSessionData]
    @Query private var spacesData: [TrainingSpaceData]
    
    @State private var selectedCategory: AchievementCategory?
    
    private var sessions: [TrainingSession] {
        sessionsData.compactMap { $0.toTrainingSession() }
    }
    
    private var spaces: [TrainingSpace] {
        spacesData.compactMap { $0.toTrainingSpace() }
    }
    
    private var circuits: [TrainingCircuit] {
        spaces.flatMap { $0.circuits }
    }
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementManager.achievements.filter { $0.category == category }
        }
        return achievementManager.achievements
    }
    
    private var unlockedCount: Int {
        achievementManager.achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress header
                    VStack(spacing: 12) {
                        Text("\(unlockedCount) / \(achievementManager.achievements.count)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.cwActiveFlow)
                        
                        Text("Achievements Unlocked")
                            .font(.headline)
                            .foregroundColor(.cwStation)
                        
                        ProgressView(value: min(Double(unlockedCount), Double(achievementManager.achievements.count)), total: Double(achievementManager.achievements.count))
                            .tint(.cwActiveFlow)
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(AchievementCategory.allCases, id: \.self) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.white)
                    
                    // Achievements grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                achievementManager.updateProgress(from: sessions, spaces: spaces, circuits: circuits)
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.category.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 40))
                    .foregroundColor(achievement.isUnlocked ? achievement.category.color : .gray.opacity(0.5))
                    .saturation(achievement.isUnlocked ? 1.0 : 0.0)
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .cwStation : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if !achievement.isUnlocked {
                    ProgressView(value: min(achievement.progress, 1.0))
                        .tint(achievement.category.color)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    Text("\(Int(achievement.progress * 100))%")
                        .font(.caption2)
                        .foregroundColor(.gray)
                } else {
                    if let date = achievement.unlockedDate {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: achievement.isUnlocked ? 
                    [Color.white, Color.white.opacity(0.98)] :
                    [Color.white.opacity(0.5), Color.white.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: achievement.isUnlocked ?
                            [achievement.category.color, achievement.category.color.opacity(0.6)] :
                            [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: achievement.isUnlocked ? 2 : 1
                )
        )
        .shadow(color: achievement.isUnlocked ? achievement.category.color.opacity(0.4) : Color.clear, radius: 15, x: 0, y: 8)
        .shadow(color: achievement.isUnlocked ? achievement.category.color.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AchievementsView()
}
