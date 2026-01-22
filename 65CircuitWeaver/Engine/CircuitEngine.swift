//
//  CircuitEngine.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftUI

class CircuitEngine {
    static func calculateOptimalPath(for stations: [Station], startAt: UUID) -> [Station] {
        guard let startStation = stations.first(where: { $0.id == startAt }) else {
            return stations
        }
        
        var remaining = stations.filter { $0.id != startAt }
        var path = [startStation]
        var current = startStation
        
        while !remaining.isEmpty {
            let nearest = remaining.min(by: { station1, station2 in
                let dist1 = distance(from: current.position, to: station1.position)
                let dist2 = distance(from: current.position, to: station2.position)
                return dist1 < dist2
            })
            
            if let nearest = nearest {
                path.append(nearest)
                remaining.removeAll { $0.id == nearest.id }
                current = nearest
            } else {
                break
            }
        }
        
        return path
    }
    
    static func calculateConnectionPath(from: CGPoint, to: CGPoint, avoiding obstacles: [Obstacle]) -> Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
    
    static func estimateTransitionTime(from: Station, to: Station, distance: CGFloat) -> TimeInterval {
        // Base time per unit distance (assuming normalized coordinates 0-1)
        // Convert to approximate meters (assuming 1 unit = ~10 meters for typical gym)
        let metersPerUnit: CGFloat = 10.0
        let actualDistance = distance * metersPerUnit
        
        // Base walking speed: ~1.4 m/s (normal walking pace)
        let baseTimePerMeter: TimeInterval = 0.7
        
        // Equipment weight penalties (time to move/adjust equipment)
        let equipmentPenalty: TimeInterval = {
            switch (from.type, to.type) {
            case (.kettlebell, .kettlebell):
                return 8.0 // Moving between kettlebells (pick up, carry, set down)
            case (.kettlebell, _), (_, .kettlebell):
                return 5.0 // Moving to/from kettlebell (pick up or set down)
            case (.box, .box):
                return 6.0 // Moving between boxes
            case (.rope, .rope):
                return 3.0 // Moving between ropes (lighter)
            case (.mat, .mat):
                return 2.0 // Moving between mats (minimal)
            case (.pullUpBar, .pullUpBar):
                return 1.0 // Moving between pull-up bars (just walking)
            default:
                return 2.0 // Mixed equipment transition
            }
        }()
        
        // Calculate base walking time
        let walkingTime = actualDistance * baseTimePerMeter
        
        // Add equipment penalty
        let totalTime = walkingTime + equipmentPenalty
        
        // Minimum transition time (even very close stations need some time)
        return max(totalTime, 5.0)
    }
    
    private static func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        return sqrt(dx * dx + dy * dy)
    }
}
