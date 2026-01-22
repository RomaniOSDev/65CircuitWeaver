//
//  SpaceLibraryView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import SwiftData

struct SpaceLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var spacesData: [TrainingSpaceData]
    
    @State private var showingBuilder = false
    @State private var selectedSpace: TrainingSpace?
    @State private var showingNameDialog = false
    @State private var newSpaceName = ""
    @State private var editingSpace: TrainingSpace?
    @State private var showingEditDialog = false
    @State private var editedSpaceName = ""
    
    private var spaces: [TrainingSpace] {
        let saved = spacesData.compactMap { $0.toTrainingSpace() }
        if saved.isEmpty {
            // Default templates
            return [
                TrainingSpace(name: "Home Gym", stations: [
                    Station(type: .kettlebell, position: CGPoint(x: 0.3, y: 0.3)),
                    Station(type: .mat, position: CGPoint(x: 0.7, y: 0.5)),
                    Station(type: .pullUpBar, position: CGPoint(x: 0.5, y: 0.2))
                ]),
                TrainingSpace(name: "CrossFit Box", stations: [
                    Station(type: .box, position: CGPoint(x: 0.2, y: 0.4)),
                    Station(type: .rope, position: CGPoint(x: 0.8, y: 0.3)),
                    Station(type: .kettlebell, position: CGPoint(x: 0.5, y: 0.6))
                ]),
                TrainingSpace(name: "Outdoor Area", stations: [
                    Station(type: .pullUpBar, position: CGPoint(x: 0.3, y: 0.3)),
                    Station(type: .mat, position: CGPoint(x: 0.7, y: 0.7))
                ]),
                TrainingSpace(name: "Empty Canvas", stations: [])
            ]
        }
        return saved
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(spaces) { space in
                            SpaceCard(space: space, action: {
                                // Для существующих пространств - они уже сохранены
                                selectedSpace = space
                                showingBuilder = true
                            }, onEdit: { spaceToEdit in
                                editingSpace = spaceToEdit
                                editedSpaceName = spaceToEdit.name
                                showingEditDialog = true
                            })
                        }
                        
                        CreateSpaceCard {
                            newSpaceName = ""
                            showingNameDialog = true
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Space Library")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingBuilder) {
                if let space = selectedSpace {
                    NavigationView {
                        // Проверяем, является ли это новым пространством (не сохранено в базе)
                        let isNew = !spaces.contains { $0.id == space.id }
                        SpaceBuilderView(space: space, isNewSpace: isNew)
                    }
                }
            }
            .alert("New Space", isPresented: $showingNameDialog) {
                TextField("Space Name", text: $newSpaceName)
                Button("Cancel", role: .cancel) {
                    newSpaceName = ""
                }
                Button("Create") {
                    let name = newSpaceName.isEmpty ? "New Space" : newSpaceName
                    // Создаем пространство, но НЕ сохраняем его сразу
                    let newSpace = TrainingSpace(name: name)
                    selectedSpace = newSpace
                    showingBuilder = true
                    newSpaceName = ""
                }
            } message: {
                Text("Enter a name for your new space")
            }
            .alert("Edit Space Name", isPresented: $showingEditDialog) {
                TextField("Space Name", text: $editedSpaceName)
                Button("Cancel", role: .cancel) {
                    editingSpace = nil
                    editedSpaceName = ""
                }
                Button("Save") {
                    if let space = editingSpace {
                        var updatedSpace = space
                        updatedSpace.name = editedSpaceName.isEmpty ? space.name : editedSpaceName
                        CircuitDataManager.shared.saveSpace(updatedSpace, to: modelContext)
                        editingSpace = nil
                        editedSpaceName = ""
                    }
                }
            } message: {
                Text("Enter a new name for this space")
            }
        }
    }
}

struct SpaceCard: View {
    let space: TrainingSpace
    let action: () -> Void
    let onEdit: (TrainingSpace) -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(space.name)
                        .font(.headline)
                        .foregroundColor(.cwStation)
                    
                    Spacer()
                    
                    Button(action: {
                        onEdit(space)
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.cwActiveFlow)
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.cwActiveFlow)
                    Text("\(space.stations.count) stations")
                        .font(.caption)
                        .foregroundColor(.cwStation.opacity(0.7))
                }
                
                if !space.circuits.isEmpty {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.cwActiveFlow)
                        Text("\(space.circuits.count) circuits")
                            .font(.caption)
                            .foregroundColor(.cwStation.opacity(0.7))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
                            colors: [Color.cwActiveFlow.opacity(0.2), Color.cwActiveFlow.opacity(0.05)],
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
}

struct CreateSpaceCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.cwActiveFlow)
                
                Text("Create Your Space")
                    .font(.headline)
                    .foregroundColor(.cwActiveFlow)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                LinearGradient(
                    colors: [Color.white, Color.cwActiveFlow.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [Color.cwActiveFlow, Color.cwActiveFlow.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.cwActiveFlow.opacity(0.3), radius: 15, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SpaceLibraryView()
}
