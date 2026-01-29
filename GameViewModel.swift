//
//  GameViewModel.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

class GameViewModel: ObservableObject {
    @Published var currentLevel: GameLevel = .easy
    @Published var cards: [MemoryCard] = []  // Changed to MemoryCard
    @Published var gameState: GameState = .notStarted
    @Published var gameStats = GameStats()
    @Published var selectedCards: [MemoryCard] = []  // Changed to MemoryCard
    @Published var showJokerAlert = false
    @Published var showWinAlert = false
    @Published var showGameOverAlert = false
    @Published var timer: Timer?
    @Published var timeRemaining: TimeInterval = 0
    @Published var isProcessing = false
    
    private let db = Firestore.firestore()
    private var sessionId: String = ""
    private var gameStartTime: Date?
    
    // Available colors for the game
    private let gameColors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple,
        .pink, .cyan, .mint, .teal, .indigo, .brown
    ]
    
    // MARK: - Game Setup
    func setupGame(level: GameLevel) {
        self.currentLevel = level
        self.gameState = .notStarted
        self.gameStats = GameStats()
        self.selectedCards = []
        self.cards = []
        self.timeRemaining = calculateTimeForLevel(level)
        
        generateCards()
        shuffleCards()
        startGame()
    }
    
    private func generateCards() {
        cards.removeAll()
        
        let pairsNeeded = currentLevel.pairsCount
        let availableColors = Array(gameColors.shuffled().prefix(pairsNeeded))
        
        var cardIndex = 0
        
        // Create pairs
        for color in availableColors {
            for _ in 0..<2 {
                cards.append(MemoryCard(
                    color: color,
                    originalColor: color,
                    isFaceUp: false,
                    isMatched: false,
                    isJoker: false,
                    index: cardIndex
                ))
                cardIndex += 1
            }
        }
        
        // Add joker card
        cards.append(MemoryCard(
            color: .black,
            originalColor: .black,
            isFaceUp: false,
            isMatched: false,
            isJoker: true,
            index: cardIndex
        ))
        
        // Fill remaining slots if needed
        let totalNeeded = currentLevel.gridSize * currentLevel.gridSize
        let currentCount = cards.count
        
        if currentCount < totalNeeded {
            for i in currentCount..<totalNeeded {
                let randomColor = gameColors.randomElement() ?? .gray
                cards.append(MemoryCard(
                    color: randomColor,
                    originalColor: randomColor,
                    isFaceUp: false,
                    isMatched: false,
                    isJoker: false,
                    index: i
                ))
            }
        }
    }
    
    private func shuffleCards() {
        cards.shuffle()
        for i in 0..<cards.count {
            cards[i].index = i
        }
    }
    
    private func calculateTimeForLevel(_ level: GameLevel) -> TimeInterval {
        switch level {
        case .easy: return 120
        case .medium: return 300
        case .hard: return 600
        }
    }
    
    // MARK: - Game Actions
    func startGame() {
        gameState = .playing
        gameStartTime = Date()
        sessionId = UUID().uuidString
        gameStats = GameStats()
        
        startTimer()
        saveGameSessionToFirebase()
    }
    
    func cardTapped(_ card: MemoryCard) {
        guard gameState == .playing,
              !isProcessing,
              !card.isFaceUp,
              !card.isMatched,
              selectedCards.count < 2 else {
            return
        }
        
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            // Create a mutable copy of the card
            var updatedCard = cards[index]
            updatedCard.isFaceUp = true
            
            // Replace the card in the array
            cards[index] = updatedCard
            
            // Check if it's a joker
            if updatedCard.isJoker {
                handleJokerCard(updatedCard)
                return
            }
            
            selectedCards.append(updatedCard)
            
            if selectedCards.count == 2 {
                checkForMatch()
            }
        }
    }

    private func flipCardBack(_ card: MemoryCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            var updatedCard = cards[index]
            updatedCard.isFaceUp = false
            cards[index] = updatedCard
        }
    }

    private func markCardAsMatched(_ card: MemoryCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            var updatedCard = cards[index]
            updatedCard.isMatched = true
            cards[index] = updatedCard
        }
    }
    
    private func checkForMatch() {
        isProcessing = true
        
        guard selectedCards.count == 2 else {
            isProcessing = false
            return
        }
        
        let card1 = selectedCards[0]
        let card2 = selectedCards[1]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.gameStats.moves += 1
            
            if card1.color == card2.color {
                self.handleMatch(card1: card1, card2: card2)
            } else {
                self.handleNoMatch(card1: card1, card2: card2)
            }
            
            self.selectedCards.removeAll()
            self.isProcessing = false
            self.checkGameCompletion()
        }
    }
    
    private func handleMatch(card1: MemoryCard, card2: MemoryCard) {
        if let index1 = cards.firstIndex(where: { $0.id == card1.id }),
           let index2 = cards.firstIndex(where: { $0.id == card2.id }) {
            
            cards[index1].isMatched = true
            cards[index2].isMatched = true
            
            gameStats.matchedPairs += 1
            gameStats.score += calculateScoreForMatch()
        }
    }
    
    private func handleNoMatch(card1: MemoryCard, card2: MemoryCard) {
        if let index1 = cards.firstIndex(where: { $0.id == card1.id }),
           let index2 = cards.firstIndex(where: { $0.id == card2.id }) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.cards[index1].isFaceUp = false
                self.cards[index2].isFaceUp = false
            }
        }
    }
    
    private func handleJokerCard(_ card: MemoryCard) {
        gameStats.jokerFound = true
        gameState = .jokerRevealed
        showJokerAlert = true
        endGame(success: false)
    }
    
    private func checkGameCompletion() {
        let matchedCards = cards.filter { $0.isMatched && !$0.isJoker }
        let totalPairs = currentLevel.pairsCount
        
        if matchedCards.count == totalPairs * 2 {
            gameState = .won
            gameStats.gameCompleted = true
            showWinAlert = true
            endGame(success: true)
        }
    }
    
    private func calculateScoreForMatch() -> Int {
        let baseScore = 100
        let timeBonus = Int(max(0, (300 - gameStats.timeSpent) / 10))
        let movesPenalty = max(0, 50 - gameStats.moves)
        return baseScore + timeBonus + movesPenalty
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.gameStats.timeSpent += 1
                
                if self.timeRemaining <= 0 && self.gameState == .playing {
                    self.handleTimeUp()
                }
            }
        }
    }
    
    private func handleTimeUp() {
        gameState = .gameOver
        showGameOverAlert = true
        endGame(success: false)
    }
    
    // MARK: - Game Control
    func restartGame() {
        timer?.invalidate()
        setupGame(level: currentLevel)
    }
    
    func pauseGame() {
        if gameState == .playing {
            gameState = .paused
            timer?.invalidate()
        }
    }
    
    func resumeGame() {
        if gameState == .paused {
            gameState = .playing
            startTimer()
        }
    }
    
    func endGame(success: Bool) {
        timer?.invalidate()
        gameState = success ? .won : .gameOver
        updateGameSessionInFirebase(success: success)
    }
    
    // MARK: - Firebase
    private func saveGameSessionToFirebase() {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            print("No user logged in")
            return
        }
        
        let device = UIDevice.current
        let deviceInfo = "\(device.model) - iOS \(device.systemVersion)"
        
        let session = GameSession(
            id: sessionId,
            userId: user.uid,
            userEmail: email,
            userNickname: UserDefaults.standard.string(forKey: "nickname_userId_\(user.uid)") ?? "Player",
            level: currentLevel,
            startTime: gameStartTime ?? Date(),
            endTime: nil,
            stats: gameStats,
            deviceInfo: deviceInfo
        )
        
        do {
            try db.collection("game_sessions").document(sessionId).setData(from: session)
        } catch {
            print("Error saving game session: \(error)")
        }
    }
    
    private func updateGameSessionInFirebase(success: Bool) {
        let endTime = Date()
        
        db.collection("game_sessions").document(sessionId).updateData([
            "endTime": endTime,
            "stats.moves": gameStats.moves,
            "stats.matchedPairs": gameStats.matchedPairs,
            "stats.timeSpent": gameStats.timeSpent,
            "stats.score": gameStats.score,
            "stats.jokerFound": gameStats.jokerFound,
            "stats.gameCompleted": gameStats.gameCompleted
        ]) { error in
            if let error = error {
                print("Error updating game session: \(error)")
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
