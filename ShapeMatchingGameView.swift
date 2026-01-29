//
//  ShapeMatchingGameView.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct ShapeMatchingGameView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var gameViewModel: ShapeGameViewModel
    
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
                    
                    Text("Matches: \(gameViewModel.gameStats.matchedPairs)/\(gameViewModel.currentLevel.pairsCount)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 50)
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color.red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                
                // Game Grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8),
                                            count: gameViewModel.currentLevel.gridSize),
                             spacing: 8) {
                        ForEach(gameViewModel.cards) { card in
                            ShapeCardView(card: card)
                                .aspectRatio(1, contentMode: .fit)
                                .onTapGesture {
                                    gameViewModel.cardTapped(card)
                                }
                                .disabled(gameViewModel.gameState != .playing || card.isMatched)
                                .opacity(card.isMatched ? 0.5 : 1.0)
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
                        navigationManager.navigateTo(.shapeMatchLevels)
                    }) {
                        ControlButton(icon: "arrow.left", text: "Exit", color: .red)
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Pause Menu Overlay
            if showPauseMenu {
                ShapePauseMenuView(gameViewModel: gameViewModel, showPauseMenu: $showPauseMenu)
            }
        }
        .navigationBarHidden(true)
        .alert("💀 Joker Found!", isPresented: $gameViewModel.showJokerAlert) {
            Button("Restart", role: .cancel) {
                gameViewModel.restartGame()
            }
            Button("Exit") {
                navigationManager.navigateTo(.shapeMatchLevels)
            }
        } message: {
            Text("You found the skull joker card! Game over. Try again!")
        }
        .alert("🎉 You Win!", isPresented: $gameViewModel.showWinAlert) {
            Button("Play Again") {
                gameViewModel.restartGame()
            }
            Button("Exit") {
                navigationManager.navigateTo(.shapeMatchLevels)
            }
        } message: {
            Text("Congratulations! You matched all shapes! Final Score: \(gameViewModel.gameStats.score)")
        }
        .alert("⏰ Time's Up!", isPresented: $gameViewModel.showGameOverAlert) {
            Button("Try Again") {
                gameViewModel.restartGame()
            }
            Button("Exit") {
                navigationManager.navigateTo(.shapeMatchLevels)
            }
        } message: {
            Text("Time's up! You matched \(gameViewModel.gameStats.matchedPairs) pairs.")
        }
        .onAppear {
            if gameViewModel.gameState == .notStarted {
                gameViewModel.startGame()
            }
        }
        .onDisappear {
            gameViewModel.pauseGame()
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ShapeCardView: View {
    let card: ShapeCard
    
    var body: some View {
        ZStack {
            // Card back (when not face up)
            if !card.isFaceUp && !card.isMatched {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.gradient)
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
                // Card front (when face up or matched)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(card.isJoker ? Color.black : card.shapeType.color, lineWidth: 3)
                    )
                    .overlay(
                        Group {
                            if card.isJoker {
                                VStack {
                                    Image(systemName: "skull")
                                        .font(.largeTitle)
                                        .foregroundColor(.black)
                                    Text("JOKER")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                            } else if card.isMatched {
                                VStack {
                                    Image(systemName: card.shapeType.systemImage)
                                        .font(.largeTitle)
                                        .foregroundColor(card.shapeType.color)
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.green)
                                }
                            } else {
                                Image(systemName: card.shapeType.systemImage)
                                    .font(.largeTitle)
                                    .foregroundColor(card.shapeType.color)
                            }
                        }
                    )
                    .shadow(color: card.isJoker ? .black : card.shapeType.color.opacity(0.3), radius: 5)
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: card.isFaceUp)
    }
}

struct ShapePauseMenuView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var gameViewModel: ShapeGameViewModel
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
                            .foregroundColor(.white)
                        Spacer()
                        Text(formatTime(gameViewModel.timeRemaining))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Moves:")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(gameViewModel.gameStats.moves)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Shapes Matched:")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(gameViewModel.gameStats.matchedPairs)/\(gameViewModel.currentLevel.pairsCount)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Score:")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(gameViewModel.gameStats.score)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
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
                        navigationManager.navigateTo(.shapeMatchLevels)
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(30)
            .background(Color.orange.opacity(0.9))
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
    let gameVM = ShapeGameViewModel()
    gameVM.setupGame(level: .easy)
    return ShapeMatchingGameView(gameViewModel: gameVM)
        .environmentObject(NavigationManager())
}
