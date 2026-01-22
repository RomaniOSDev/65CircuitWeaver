//
//  TrainingHistory.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation

struct TrainingSession: Identifiable, Codable {
    let id: UUID
    let circuitId: UUID
    let circuitName: String
    let spaceId: UUID
    let spaceName: String
    let startDate: Date
    var endDate: Date?
    var completedRounds: Int
    var totalRounds: Int
    var stationTimes: [UUID: TimeInterval] // stationId -> actual time
    var transitionTimes: [UUID: TimeInterval] // connectionId -> actual time
    var notes: String?
    var rating: Int? // 1-5 stars
    
    var duration: TimeInterval? {
        guard let endDate = endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }
    
    var isCompleted: Bool {
        completedRounds >= totalRounds
    }
    
    init(id: UUID = UUID(), circuitId: UUID, circuitName: String, spaceId: UUID, spaceName: String, startDate: Date = Date(), totalRounds: Int) {
        self.id = id
        self.circuitId = circuitId
        self.circuitName = circuitName
        self.spaceId = spaceId
        self.spaceName = spaceName
        self.startDate = startDate
        self.completedRounds = 0
        self.totalRounds = totalRounds
        self.stationTimes = [:]
        self.transitionTimes = [:]
    }
}

struct TrainingStatistics {
    let totalSessions: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let completedSessions: Int
    let favoriteCircuit: String?
    let totalRounds: Int
    let longestStreak: Int // days in a row
    let currentStreak: Int
    let sessionsByWeek: [Date: Int]
    let improvementTrend: [Date: TimeInterval] // date -> average duration
    
    static func calculate(from sessions: [TrainingSession]) -> TrainingStatistics {
        let completed = sessions.filter { $0.isCompleted }
        let totalDuration = completed.compactMap { $0.duration }.reduce(0, +)
        let averageDuration = completed.isEmpty ? 0 : totalDuration / Double(completed.count)
        
        // Calculate streaks
        let sortedSessions = sessions.sorted { $0.startDate < $1.startDate }
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for session in sortedSessions where session.isCompleted {
            let sessionDate = Calendar.current.startOfDay(for: session.startDate)
            if let last = lastDate {
                let daysBetween = Calendar.current.dateComponents([.day], from: last, to: sessionDate).day ?? 0
                if daysBetween == 1 {
                    currentStreak += 1
                } else if daysBetween > 1 {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            lastDate = sessionDate
        }
        longestStreak = max(longestStreak, currentStreak)
        
        // Group by week
        let calendar = Calendar.current
        var sessionsByWeek: [Date: Int] = [:]
        for session in completed {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: session.startDate)?.start ?? session.startDate
            sessionsByWeek[weekStart, default: 0] += 1
        }
        
        // Favorite circuit
        let circuitCounts = Dictionary(grouping: completed, by: { $0.circuitName })
        let favoriteCircuit = circuitCounts.max(by: { $0.value.count < $1.value.count })?.key
        
        // Improvement trend (average duration by week)
        var improvementTrend: [Date: TimeInterval] = [:]
        let sessionsByWeekGrouped = Dictionary(grouping: completed) { session in
            calendar.dateInterval(of: .weekOfYear, for: session.startDate)?.start ?? session.startDate
        }
        for (week, weekSessions) in sessionsByWeekGrouped {
            let avgDuration = weekSessions.compactMap { $0.duration }.reduce(0, +) / Double(weekSessions.count)
            improvementTrend[week] = avgDuration
        }
        
        return TrainingStatistics(
            totalSessions: sessions.count,
            totalDuration: totalDuration,
            averageDuration: averageDuration,
            completedSessions: completed.count,
            favoriteCircuit: favoriteCircuit,
            totalRounds: completed.reduce(0) { $0 + $1.completedRounds },
            longestStreak: longestStreak,
            currentStreak: currentStreak,
            sessionsByWeek: sessionsByWeek,
            improvementTrend: improvementTrend
        )
    }
}
