//
//  SpaceBuilderView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import Combine

enum BuilderTool {
    case station
    case draw
    case measure
}

struct SpaceBuilderView: View {
    @StateObject private var viewModel: SpaceBuilderViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTool: BuilderTool = .station
    @State private var selectedStationType: StationType = .kettlebell
    @State private var isDrawing = false
    @State private var showingNameEdit = false
    @State private var editedName = ""
    @State private var isSaved = false
    @State private var measuringStart: CGPoint?
    @State private var measuringEnd: CGPoint?
    @State private var showingMeasurement = false
    
    let initialSpace: TrainingSpace
    let isNewSpace: Bool
    
    init(space: TrainingSpace, isNewSpace: Bool = false) {
        self.initialSpace = space
        self.isNewSpace = isNewSpace
        _viewModel = StateObject(wrappedValue: SpaceBuilderViewModel(space: space))
    }
    
    private var spaceId: UUID {
        viewModel.space.id
    }
    
    var body: some View {
        ZStack {
            Color.cwBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Canvas
                GeometryReader { geometry in
                    ZStack {
                        // Background grid
                        Canvas { context, size in
                            let gridSize: CGFloat = 20
                            context.stroke(
                                Path { path in
                                    for i in stride(from: 0, through: size.width, by: gridSize) {
                                        path.move(to: CGPoint(x: i, y: 0))
                                        path.addLine(to: CGPoint(x: i, y: size.height))
                                    }
                                    for i in stride(from: 0, through: size.height, by: gridSize) {
                                        path.move(to: CGPoint(x: 0, y: i))
                                        path.addLine(to: CGPoint(x: size.width, y: i))
                                    }
                                },
                                with: .color(.gray.opacity(0.2)),
                                lineWidth: 1
                            )
                        }
                        
                        // Obstacles - displayed outside Canvas
                        ForEach(viewModel.obstacles) { obstacle in
                            Path { path in
                                if let first = obstacle.path.first {
                                    path.move(to: first)
                                    for point in obstacle.path.dropFirst() {
                                        path.addLine(to: point)
                                    }
                                }
                            }
                            .stroke(Color.gray, lineWidth: 3)
                        }
                        
                        // Stations
                        ForEach(viewModel.stations) { station in
                            StationView(
                                station: station,
                                isDragging: viewModel.draggingStationId == station.id
                            )
                            .position(
                                x: station.position.x * geometry.size.width,
                                y: station.position.y * geometry.size.height
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let newPosition = CGPoint(
                                            x: max(0, min(1, value.location.x / geometry.size.width)),
                                            y: max(0, min(1, value.location.y / geometry.size.height))
                                        )
                                        viewModel.startDragging(station.id)
                                        viewModel.updateStationPosition(station.id, to: newPosition)
                                    }
                                    .onEnded { _ in
                                        viewModel.stopDragging()
                                    }
                            )
                        }
                        
                        // Drawing path
                        if isDrawing, let currentPath = viewModel.currentDrawingPath {
                            currentPath
                                .stroke(Color.gray, lineWidth: 2)
                        }
                        
                        // Measurement line
                        if selectedTool == .measure, let start = measuringStart, let end = measuringEnd {
                            Path { path in
                                path.move(to: start)
                                path.addLine(to: end)
                            }
                            .stroke(Color.cwActiveFlow, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            
                            // Distance label
                            let distance = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))
                            let meters = (distance / geometry.size.width) * 10 // Approximate conversion
                            
                            Text(String(format: "%.1f m", meters))
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.cwActiveFlow)
                                .cornerRadius(6)
                                .position(
                                    x: (start.x + end.x) / 2,
                                    y: (start.y + end.y) / 2 - 20
                                )
                        }
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if selectedTool == .station {
                                    let relativePosition = CGPoint(
                                        x: value.location.x / geometry.size.width,
                                        y: value.location.y / geometry.size.height
                                    )
                                    viewModel.addStation(type: selectedStationType, at: relativePosition)
                                } else if selectedTool == .draw {
                                    isDrawing = true
                                    viewModel.addDrawingPoint(value.location)
                                } else if selectedTool == .measure {
                                    if measuringStart == nil {
                                        measuringStart = value.startLocation
                                    }
                                    measuringEnd = value.location
                                    showingMeasurement = true
                                }
                            }
                            .onEnded { value in
                                if selectedTool == .draw {
                                    isDrawing = false
                                    viewModel.finishDrawing()
                                } else if selectedTool == .measure {
                                    // Keep measurement visible for a moment
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        measuringStart = nil
                                        measuringEnd = nil
                                        showingMeasurement = false
                                    }
                                }
                            }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Toolbar
                VStack(spacing: 12) {
                    // Station type selector
                    if selectedTool == .station {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(StationType.allCases, id: \.self) { type in
                                            Button(action: {
                                                selectedStationType = type
                                            }) {
                                                VStack(spacing: 4) {
                                                    Image(systemName: type.iconName)
                                                        .font(.title2)
                                                    Text(type.displayName)
                                                        .font(.caption)
                                                }
                                                .foregroundColor(selectedStationType == type ? .white : .cwStation)
                                                .padding()
                                                .background(selectedStationType == type ? Color.cwActiveFlow : Color.white)
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                    }
                    
                    // Tool selector
                    HStack(spacing: 20) {
                                ToolButton(
                                    icon: "mappin.circle.fill",
                                    title: "Station",
                                    isSelected: selectedTool == .station
                                ) {
                                    selectedTool = .station
                                }
                                
                                ToolButton(
                                    icon: "pencil",
                                    title: "Draw",
                                    isSelected: selectedTool == .draw
                                ) {
                                    selectedTool = .draw
                                }
                                
                                ToolButton(
                                    icon: "ruler",
                                    title: "Measure",
                                    isSelected: selectedTool == .measure
                                ) {
                                    selectedTool = .measure
                                }
                    }
                    .padding()
                    .background(Color.white)
                }
            }
            .navigationTitle(viewModel.space.name)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Обновляем данные при появлении экрана
                viewModel.updateFromSpace()
                editedName = viewModel.space.name
                // Если это новое пространство, помечаем как не сохраненное
                if isNewSpace {
                    isSaved = false
                } else {
                    // Если это существующее пространство, считаем его уже сохраненным
                    isSaved = true
                }
            }
            .id(spaceId) // Принудительное обновление при изменении space
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        editedName = viewModel.space.name
                        showingNameEdit = true
                    }) {
                        HStack(spacing: 4) {
                            Text(viewModel.space.name)
                                .font(.headline)
                                .foregroundColor(.cwStation)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.cwActiveFlow)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.cwStation)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.stations.isEmpty {
                        NavigationLink(destination: CircuitWeaverView(space: viewModel.space).navigationBarBackButtonHidden(false)) {
                            Text("Weave Circuit")
                                .foregroundColor(.cwActiveFlow)
                        }
                        .onAppear {
                            // Сохраняем пространство только при переходе к плетению круга
                            isSaved = true
                            CircuitDataManager.shared.saveSpace(viewModel.space, to: modelContext)
                        }
                    } else {
                        Button("Save") {
                            // Сохраняем пространство только при явном сохранении
                            isSaved = true
                            CircuitDataManager.shared.saveSpace(viewModel.space, to: modelContext)
                            dismiss()
                        }
                        .foregroundColor(.cwActiveFlow)
                    }
                }
            }
            .onDisappear {
                // Если пространство не было сохранено явно и нет станций, не сохраняем
                // Это предотвращает создание пустых пространств при закрытии без сохранения
            }
            .alert("Edit Space Name", isPresented: $showingNameEdit) {
                TextField("Space Name", text: $editedName)
                Button("Cancel", role: .cancel) {
                    editedName = viewModel.space.name
                }
                Button("Save") {
                    if !editedName.isEmpty {
                        viewModel.space.name = editedName
                        // Сохраняем только если пространство уже было сохранено ранее
                        // или если есть станции (значит пользователь что-то создал)
                        if isSaved || !viewModel.stations.isEmpty {
                            CircuitDataManager.shared.saveSpace(viewModel.space, to: modelContext)
                        }
                    }
                }
            } message: {
                Text("Enter a new name for this space")
            }
        }
    }
}

struct StationView: View {
    let station: Station
    var isDragging: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isDragging ? Color.cwActiveFlow : Color.cwStation)
                .frame(width: isDragging ? 50 : 40, height: isDragging ? 50 : 40)
                .shadow(color: isDragging ? Color.cwActiveFlow.opacity(0.5) : Color.clear, radius: 10)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
            
            Image(systemName: station.iconName)
                .foregroundColor(.white)
                .font(.system(size: isDragging ? 24 : 20))
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
        }
    }
}

struct ToolButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .cwStation)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.cwActiveFlow : Color.white)
            .cornerRadius(8)
        }
    }
}

class SpaceBuilderViewModel: ObservableObject {
    @Published var space: TrainingSpace
    @Published var stations: [Station] = []
    @Published var obstacles: [Obstacle] = []
    @Published var currentDrawingPath: Path?
    @Published var draggingStationId: UUID?
    
    private var drawingPoints: [CGPoint] = []
    
    init(space: TrainingSpace) {
        self.space = space
        self.stations = space.stations
        self.obstacles = space.obstacles ?? []
    }
    
    func startDragging(_ stationId: UUID) {
        draggingStationId = stationId
    }
    
    func stopDragging() {
        draggingStationId = nil
    }
    
    func addStation(type: StationType, at position: CGPoint) {
        let newStation = Station(type: type, position: position)
        stations.append(newStation)
        space.stations = stations
    }
    
    func updateStationPosition(_ stationId: UUID, to position: CGPoint) {
        if let index = stations.firstIndex(where: { $0.id == stationId }) {
            stations[index].position = position
            space.stations = stations
        }
    }
    
    func addDrawingPoint(_ point: CGPoint) {
        drawingPoints.append(point)
        updateDrawingPath()
    }
    
    func finishDrawing() {
        if drawingPoints.count > 1 {
            let obstacle = Obstacle(path: drawingPoints)
            obstacles.append(obstacle)
            space.obstacles = obstacles
        }
        drawingPoints = []
        currentDrawingPath = nil
    }
    
    private func updateDrawingPath() {
        guard !drawingPoints.isEmpty else {
            currentDrawingPath = nil
            return
        }
        
        var path = Path()
        if let first = drawingPoints.first {
            path.move(to: first)
            for point in drawingPoints.dropFirst() {
                path.addLine(to: point)
            }
        }
        currentDrawingPath = path
    }
    
    func updateFromSpace() {
        // Обновляем stations и obstacles из space при необходимости
        if stations.count != space.stations.count {
            stations = space.stations
        }
        if obstacles.count != (space.obstacles?.count ?? 0) {
            obstacles = space.obstacles ?? []
        }
    }
}

#Preview {
    SpaceBuilderView(space: TrainingSpace(name: "Test Space"))
}
