//
//  Station.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI

enum StationType: String, CaseIterable, Codable {
    case kettlebell
    case pullUpBar
    case mat
    case box
    case rope
    
    var iconName: String {
        switch self {
        case .kettlebell: return "dumbbell.fill"
        case .pullUpBar: return "figure.strengthtraining.traditional"
        case .mat: return "rectangle.fill"
        case .box: return "cube.fill"
        case .rope: return "waveform.path"
        }
    }
    
    var displayName: String {
        switch self {
        case .kettlebell: return "Kettlebell"
        case .pullUpBar: return "Pull-up Bar"
        case .mat: return "Mat"
        case .box: return "Box"
        case .rope: return "Rope"
        }
    }
}

struct Station: Identifiable, Codable {
    let id: UUID
    var type: StationType
    var positionX: Double
    var positionY: Double
    var customName: String?
    
    init(id: UUID = UUID(), type: StationType, position: CGPoint, customName: String? = nil) {
        self.id = id
        self.type = type
        self.positionX = Double(position.x)
        self.positionY = Double(position.y)
        self.customName = customName
    }
    
    var position: CGPoint {
        get {
            CGPoint(x: positionX, y: positionY)
        }
        set {
            positionX = Double(newValue.x)
            positionY = Double(newValue.y)
        }
    }
    
    var iconName: String {
        type.iconName
    }
}

struct ObstaclePoint: Codable {
    let x: Double
    let y: Double
}

struct Obstacle: Identifiable, Codable {
    let id: UUID
    var pathPoints: [ObstaclePoint]
    
    init(id: UUID = UUID(), path: [CGPoint]) {
        self.id = id
        self.pathPoints = path.map { ObstaclePoint(x: Double($0.x), y: Double($0.y)) }
    }
    
    var path: [CGPoint] {
        get {
            pathPoints.map { CGPoint(x: $0.x, y: $0.y) }
        }
        set {
            pathPoints = newValue.map { ObstaclePoint(x: Double($0.x), y: Double($0.y)) }
        }
    }
}
