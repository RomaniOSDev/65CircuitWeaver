//
//  MainTabView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                
                SpaceLibraryView()
                    .tag(1)
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("Spaces")
                    }
                
                ExerciseLibraryView()
                    .tag(2)
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Exercises")
                    }
                
                TrainingProgramsView()
                    .tag(3)
                    .tabItem {
                        Image(systemName: "list.bullet.rectangle")
                        Text("Programs")
                    }
                
                TrainingHistoryView()
                    .tag(4)
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("History")
                    }
                
                AchievementsView()
                    .tag(5)
                    .tabItem {
                        Image(systemName: "trophy.fill")
                        Text("Achievements")
                    }
                
                SettingsView()
                    .tag(6)
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
            }
            
            // Центральная большая кнопка поверх TabBar
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            selectedTab = 0
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cwActiveFlow, Color.cwActiveFlow.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)
                                .shadow(color: Color.cwActiveFlow.opacity(0.5), radius: 15, x: 0, y: 8)
                            
                            Image(systemName: "house.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -35)
                    .scaleEffect(selectedTab == 0 ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)
                    
                    Spacer()
                }
            }
            .allowsHitTesting(true)
        }
    }
}

#Preview {
    MainTabView()
}
