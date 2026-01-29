//
//  HomeView.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Use the renamed HomeGame model
    let games: [HomeGame] = [
        HomeGame(name: "Memory Match", icon: "square.grid.3x3.fill", color: .blue),
        HomeGame(name: "Shape Matcher", icon: "square.on.circle", color: .orange)
        
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                HStack {
                    Text("GameSphere")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Display user nickname or email
                    if let user = authViewModel.currentUser {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(user.nickname)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
                
                Text("Your Gaming Universe")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 50)
            .padding(.bottom, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Games Grid - Use GameSelectionCard component
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(games) { game in
                        GameSelectionCard(game: game)
                            .onTapGesture {
                                handleGameTap(game.name)
                            }
                    }
                }
                .padding()
            }
            
            // Bottom Navigation Bar
            HStack {
                // Home Button
                Button(action: {
                    navigationManager.navigateTo(.home)
                }) {
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.title2)
                        Text("Home")
                            .font(.caption)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                
                // Profile Button
                Button(action: {
                    navigationManager.navigateTo(.profile)
                }) {
                    VStack {
                        Image(systemName: "person.fill")
                            .font(.title2)
                        Text("Profile")
                            .font(.caption)
                    }
                    
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .shadow(color: .gray.opacity(0.1), radius: 5, y: -2)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
    
    private func handleGameTap(_ gameName: String) {
        switch gameName {
        case "Memory Match":
            navigationManager.navigateTo(.memoryMatchLevels)
        case "Shape Matcher":
            navigationManager.navigateTo(.shapeMatchLevels)
        default:
            print("Game \(gameName) not implemented yet")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationManager())
        .environmentObject(AuthViewModel())
}
