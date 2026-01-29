//
//  MemoryMatchGameView.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct MemoryMatchGameView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var gameViewModel: GameViewModel
    
    @State private var showPauseMenu = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    HStack {
                        Text(gameViewModel.currentLevel.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 5) {
                            Text("Time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(formatTime(gameViewModel.timeRemaining))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(gameViewModel.timeRemaining < 60 ? .red : .white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(gameViewModel.gameStats.score)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Pairs: \(gameViewModel.gameStats.matchedPairs)/\(gameViewModel.currentLevel.pairsCount)")
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
                
                // Game Grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8),
                                            count: gameViewModel.currentLevel.gridSize),
                             spacing: 8) {
                        ForEach($gameViewModel.cards) { $card in
                            MemoryCardView(card: $card)
                                .aspectRatio(1, contentMode: .fit)
                                .onTapGesture {
                                    gameViewModel.cardTapped(card)
                                }
                                .disabled(gameViewModel.gameState != .playing || card.isMatched)
                        }
                    }
                    .padding()
                }
                
                // Controls
                HStack(spacing: 20) {
                    Button(action: {
                        gameViewModel.restartGame()
                    }) {
                        ControlButton(icon: "arrow.clockwise", text: "Restart", color: .orange)
                    }
                    
                    Button(action: {
                        if gameViewModel.gameState == .playing {
                            gameViewModel.pauseGame()
                            showPauseMenu = true
                        } else if gameViewModel.gameState == .paused {
                            gameViewModel.resumeGame()
                            showPauseMenu = false
                        }
                    }) {
                        ControlButton(
                            icon: gameViewModel.gameState == .playing ? "pause.fill" : "play.fill",
                            text: gameViewModel.gameState == .playing ? "Pause" : "Resume",
                            color: .blue
                        )
                    }
                    
                    Button(action: {
                        navigationManager.navigateTo(.memoryMatchLevels)
                    }) {
                        ControlButton(icon: "arrow.left", text: "Exit", color: .red)
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Pause Menu Overlay
            if showPauseMenu {
                PauseMenuView(gameViewModel: gameViewModel, showPauseMenu: $showPauseMenu)
            }
        }
        .navigationBarHidden(true)
        .alert("🎭 Joker Found!", isPresented: $gameViewModel.showJokerAlert) {
            Button("Restart", role: .cancel) {
                gameViewModel.restartGame()
            }
            Button("Exit") {
                navigationManager.navigateTo(.memoryMatchLevels)
            }
        } message: {
            Text("You found the black joker card! Game over. Try again!")
        }
        .alert("🎉 You Win!", isPresented: $gameViewModel.showWinAlert) {
            Button("Play Again") {
                gameViewModel.restartGame()
            }
            Button("Exit") {
                navigationManager.navigateTo(.memoryMatchLevels)
            }
        } message: {
            Text("Congratulations! Score: \(gameViewModel.gameStats.score)")
        }
        .alert("⏰ Time's Up!", isPresented: $gameViewModel.showGameOverAlert) {
            Button("Try Again") {
                gameViewModel.restartGame()
            }
            Button("Exit") {
                navigationManager.navigateTo(.memoryMatchLevels)
            }
        } message: {
            Text("Time's up! You matched \(gameViewModel.gameStats.matchedPairs) pairs.")
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct MemoryCardView: View {
    @Binding var card: MemoryCard
    
    var body: some View {
        ZStack {
            if !card.isFaceUp && !card.isMatched {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.gradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: "questionmark")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.7))
                    )
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(card.color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(card.isJoker ? Color.black : Color.white, lineWidth: 3)
                    )
                    .overlay(
                        Group {
                            if card.isJoker {
                                Image(systemName: "theatermasks.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            } else if card.isMatched {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                    )
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: card.isFaceUp)
    }
}

struct ControlButton: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
            
            Text(text)
                .font(.caption)
        }
        .frame(width: 80, height: 60)
        .foregroundColor(.white)
        .background(color)
        .cornerRadius(10)
    }
}

struct PauseMenuView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var gameViewModel: GameViewModel
    @Binding var showPauseMenu: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("Game Paused")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    HStack {
                        Text("Time Left:")
                        Spacer()
                        Text(formatTime(gameViewModel.timeRemaining))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    
                    HStack {
                        Text("Moves:")
                        Spacer()
                        Text("\(gameViewModel.gameStats.moves)")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    
                    HStack {
                        Text("Pairs Matched:")
                        Spacer()
                        Text("\(gameViewModel.gameStats.matchedPairs)/\(gameViewModel.currentLevel.pairsCount)")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    
                    HStack {
                        Text("Score:")
                        Spacer()
                        Text("\(gameViewModel.gameStats.score)")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                
                HStack(spacing: 20) {
                    Button("Resume") {
                        gameViewModel.resumeGame()
                        showPauseMenu = false
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Restart") {
                        gameViewModel.restartGame()
                        showPauseMenu = false
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Quit") {
                        navigationManager.navigateTo(.memoryMatchLevels)
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(30)
            .background(Color.blue.opacity(0.9))
            .cornerRadius(20)
            .padding(.horizontal, 40)
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    let gameVM = GameViewModel()
    gameVM.setupGame(level: .easy)
    return MemoryMatchGameView(gameViewModel: gameVM)
        .environmentObject(NavigationManager())
}
