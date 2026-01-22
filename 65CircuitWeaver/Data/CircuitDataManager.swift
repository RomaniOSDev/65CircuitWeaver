//
//  CircuitDataManager.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import Foundation
import SwiftData

class CircuitDataManager {
    static let shared = CircuitDataManager()
    
    private init() {}
    
    func saveSpace(_ space: TrainingSpace, to context: ModelContext) {
        if let existing = fetchSpace(by: space.id, from: context) {
            existing.update(from: space)
        } else {
            let spaceData = TrainingSpaceData(
                id: space.id,
                name: space.name,
                stations: space.stations,
                obstacles: space.obstacles,
                circuits: space.circuits
            )
            context.insert(spaceData)
        }
        
        try? context.save()
    }
    
    func fetchSpace(by id: UUID, from context: ModelContext) -> TrainingSpaceData? {
        let descriptor = FetchDescriptor<TrainingSpaceData>(
            predicate: #Predicate { $0.id == id }
        )
        return try? context.fetch(descriptor).first
    }
    
    func fetchAllSpaces(from context: ModelContext) -> [TrainingSpace] {
        let descriptor = FetchDescriptor<TrainingSpaceData>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let spacesData = try? context.fetch(descriptor) else {
            return []
        }
        return spacesData.compactMap { $0.toTrainingSpace() }
    }
    
    func deleteSpace(_ space: TrainingSpace, from context: ModelContext) {
        if let existing = fetchSpace(by: space.id, from: context) {
            context.delete(existing)
            try? context.save()
        }
    }
}
