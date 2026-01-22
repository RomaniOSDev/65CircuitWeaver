//
//  Achievements.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI
import Combine

struct Achievement: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var icon: String
    var category: AchievementCategory
    var requirement: AchievementRequirement
    var isUnlocked: Bool
    var unlockedDate: Date?
    var progress: Double // 0.0 - 1.0
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, category: AchievementCategory, requirement: AchievementRequirement, isUnlocked: Bool = false, unlockedDate: Date? = nil, progress: Double = 0.0) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.category = category
        self.requirement = requirement
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.progress = progress
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case consistency = "Consistency"
    case performance = "Performance"
    case exploration = "Exploration"
    case mastery = "Mastery"
    case social = "Social"
    
    var color: Color {
        switch self {
        case .consistency: return .blue
        case .performance: return .orange
        case .exploration: return .green
        case .mastery: return .purple
        case .social: return .pink
        }
    }
}

enum AchievementRequirement: Codable {
    case sessions(count: Int)
    case rounds(count: Int)
    case streak(days: Int)
    case circuitCompletion(circuitId: UUID)
    case timeSpent(hours: Double)
    case spacesCreated(count: Int)
    case circuitsCreated(count: Int)
    case perfectSession // All rounds completed on time
    
    var description: String {
        switch self {
        case .sessions(let count):
            return "Complete \(count) training sessions"
        case .rounds(let count):
            return "Complete \(count) total rounds"
        case .streak(let days):
            return "Train for \(days) days in a row"
        case .circuitCompletion(let circuitId):
            return "Complete circuit"
        case .timeSpent(let hours):
            return "Spend \(Int(hours)) hours training"
        case .spacesCreated(let count):
            return "Create \(count) training spaces"
        case .circuitsCreated(let count):
            return "Create \(count) circuits"
        case .perfectSession:
            return "Complete a session with perfect timing"
        }
    }
}

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    init() {
        loadDefaultAchievements()
    }
    
    private func loadDefaultAchievements() {
        achievements = [
            // Consistency
            Achievement(
                title: "First Steps",
                description: "Complete your first training session",
                icon: "figure.walk",
                category: .consistency,
                requirement: .sessions(count: 1)
            ),
            Achievement(
                title: "Week Warrior",
                description: "Train for 7 days in a row",
                icon: "calendar",
                category: .consistency,
                requirement: .streak(days: 7)
            ),
            Achievement(
                title: "Month Master",
                description: "Train for 30 days in a row",
                icon: "calendar.badge.clock",
                category: .consistency,
                requirement: .streak(days: 30)
            ),
            Achievement(
                title: "Century Club",
                description: "Complete 100 training sessions",
                icon: "100.circle.fill",
                category: .consistency,
                requirement: .sessions(count: 100)
            ),
            
            // Performance
            Achievement(
                title: "Round Master",
                description: "Complete 50 total rounds",
                icon: "arrow.triangle.2.circlepath",
                category: .performance,
                requirement: .rounds(count: 50)
            ),
            Achievement(
                title: "Perfect Timing",
                description: "Complete a session with perfect timing",
                icon: "checkmark.circle.fill",
                category: .performance,
                requirement: .perfectSession
            ),
            Achievement(
                title: "Time Champion",
                description: "Spend 10 hours training",
                icon: "clock.fill",
                category: .performance,
                requirement: .timeSpent(hours: 10)
            ),
            
            // Exploration
            Achievement(
                title: "Space Creator",
                description: "Create your first training space",
                icon: "mappin.circle.fill",
                category: .exploration,
                requirement: .spacesCreated(count: 1)
            ),
            Achievement(
                title: "Circuit Designer",
                description: "Create 5 different circuits",
                icon: "arrow.triangle.2.circlepath.circle.fill",
                category: .exploration,
                requirement: .circuitsCreated(count: 5)
            ),
            Achievement(
                title: "Architect",
                description: "Create 10 training spaces",
                icon: "building.2.fill",
                category: .exploration,
                requirement: .spacesCreated(count: 10)
            ),
            
            // Mastery
            Achievement(
                title: "Circuit Master",
                description: "Complete all circuits in a program",
                icon: "star.fill",
                category: .mastery,
                requirement: .circuitsCreated(count: 1)
            )
        ]
    }
    
    func updateProgress(from sessions: [TrainingSession], spaces: [TrainingSpace], circuits: [TrainingCircuit]) {
        let stats = TrainingStatistics.calculate(from: sessions)
        
        for index in achievements.indices {
            var achievement = achievements[index]
            
            switch achievement.requirement {
            case .sessions(let count):
                achievement.progress = min(1.0, Double(stats.totalSessions) / Double(count))
                if stats.totalSessions >= count && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
                
            case .rounds(let count):
                achievement.progress = min(1.0, Double(stats.totalRounds) / Double(count))
                if stats.totalRounds >= count && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
                
            case .streak(let days):
                let currentStreak = stats.currentStreak
                achievement.progress = min(1.0, Double(currentStreak) / Double(days))
                if currentStreak >= days && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
                
            case .timeSpent(let hours):
                let totalHours = stats.totalDuration / 3600
                achievement.progress = min(1.0, totalHours / hours)
                if totalHours >= hours && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
                
            case .spacesCreated(let count):
                achievement.progress = min(1.0, Double(spaces.count) / Double(count))
                if spaces.count >= count && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
                
            case .circuitsCreated(let count):
                let totalCircuits = spaces.reduce(0) { $0 + $1.circuits.count }
                achievement.progress = min(1.0, Double(totalCircuits) / Double(count))
                if totalCircuits >= count && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
                
            case .circuitCompletion, .perfectSession:
                // These need specific session data
                break
            }
            
            achievements[index] = achievement
        }
    }
}
