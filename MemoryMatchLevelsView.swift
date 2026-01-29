//
//  MemoryMatchLevelsView.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct MemoryMatchLevelsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.blue)
                        
                        Text("Memory Match")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        
                        Text("Match colors, avoid the joker!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                    
                    VStack(spacing: 20) {
                        Text("Select Level")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(GameLevel.allCases, id: \.self) { level in
                            Button(action: {
                                let gameViewModel = GameViewModel()
                                gameViewModel.setupGame(level: level)
                                navigationManager.navigateTo(.gameView(gameViewModel))
                            }) {
                                LevelCard(level: level)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        navigationManager.navigateTo(.home)
                    }) {
                        Text("Back to Home")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct LevelCard: View {
    let level: GameLevel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(level.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("\(level.gridSize)×\(level.gridSize) Grid")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(level.pairsCount) pairs, 1 joker")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(timeForLevel(level))
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(getBorderColor(for: level), lineWidth: 2)
        )
    }
    
    private func timeForLevel(_ level: GameLevel) -> String {
        switch level {
        case .easy: return "2 min"
        case .medium: return "5 min"
        case .hard: return "10 min"
        }
    }
    
    private func getBorderColor(for level: GameLevel) -> Color {
        switch level {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

#Preview {
    MemoryMatchLevelsView()
        .environmentObject(NavigationManager())
}
