//
//  SettingsView.swift
//  65CircuitWeaver
//
//  Created by Роман Главацкий on 22.01.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cwBackground
                    .ignoresSafeArea()
                
                List {
                    Section {
                        SettingsRow(
                            icon: "star.fill",
                            iconColor: .yellow,
                            title: "Rate Us",
                            action: {
                                rateApp()
                            }
                        )
                        
                        SettingsRow(
                            icon: "lock.shield.fill",
                            iconColor: .blue,
                            title: "Privacy Policy",
                            action: {
                                openPrivacyPolicy()
                            }
                        )
                        
                        SettingsRow(
                            icon: "doc.text.fill",
                            iconColor: .green,
                            title: "Terms of Service",
                            action: {
                                openTermsOfService()
                            }
                        )
                    } header: {
                        Text("About")
                    } footer: {
                        Text("We value your feedback and privacy")
                    }
                    
                    Section {
                        SettingsRow(
                            icon: "arrow.clockwise.circle.fill",
                            iconColor: .orange,
                            title: "Show Onboarding",
                            action: {
                                showingOnboarding = true
                            }
                        )
                    } header: {
                        Text("Help")
                    }
                    
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Text("Circuit Weaver")
                                    .font(.headline)
                                    .foregroundColor(.cwStation)
                                
                                Text("Version 1.0.0")
                                    .font(.caption)
                                    .foregroundColor(.cwStation.opacity(0.7))
                                
                                Text("© 2026 Circuit Weaver")
                                    .font(.caption2)
                                    .foregroundColor(.cwStation.opacity(0.5))
                            }
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingView()
            }
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.termsfeed.com/live/f730c3a5-d07b-4044-9482-5c58de054b0a") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://www.termsfeed.com/live/6730f935-9a4e-4333-9f7c-f45b5989d4c1") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.cwStation)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.cwStation.opacity(0.3))
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
