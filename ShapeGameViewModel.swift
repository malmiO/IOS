//
//  ShapeGameViewModel.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

class ShapeGameViewModel: ObservableObject {
    @Published var currentLevel: GameLevel = .easy
    @Published var cards: [ShapeCard] = []
    @Published var gameState: GameState = .notStarted
    @Published var gameStats = GameStats()
    @Published var selectedCards: [ShapeCard] = []
    @Published var showJokerAlert = false
    @Published var showWinAlert = false
    @Published var showGameOverAlert = false
    @Published var timer: Timer?
    @Published var timeRemaining: TimeInterval = 0
    @Published var isProcessing = false
    
    private let db = Firestore.firestore()
    private var sessionId: String = ""
    private var gameStartTime: Date?
    
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
        let allShapes = ShapeType.allCases
        
        // Make sure we have enough shapes
        let availableShapes = Array(allShapes.shuffled().prefix(min(pairsNeeded, allShapes.count)))
        
        var cardIndex = 0
        
        // Create pairs
        for shape in availableShapes {
            for _ in 0..<2 {
                cards.append(ShapeCard(
                    shapeType: shape,
                    isFaceUp: false,
                    isMatched: false,
                    isJoker: false,
                    index: cardIndex
                ))
                cardIndex += 1
            }
        }
        
        // Add joker card
        cards.append(ShapeCard(
            shapeType: .circle, // Default shape, but marked as joker
            isFaceUp: false,
            isMatched: false,
            isJoker: true,
            index: cardIndex
        ))
        
        // Fill remaining slots if needed
        let totalNeeded = currentLevel.gridSize * currentLevel.gridSize
        while cards.count < totalNeeded {
            let randomShape = allShapes.randomElement() ?? .circle
            cards.append(ShapeCard(
                shapeType: randomShape,
                isFaceUp: false,
                isMatched: false,
                isJoker: false,
                index: cards.count
            ))
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
        case .medium: return 180
        case .hard: return 240
        }
    }
    
    // MARK: - Game Actions
    func startGame() {
        gameState = .playing
        gameStartTime = Date()
        sessionId = UUID().uuidString
        gameStats = GameStats()
        
        startTimer()
    }
    
    func cardTapped(_ card: ShapeCard) {
        guard gameState == .playing,
              !isProcessing,
              !card.isFaceUp,
              !card.isMatched,
              selectedCards.count < 2 else {
            return
        }
        
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            var updatedCard = cards[index]
            updatedCard.isFaceUp = true
            cards[index] = updatedCard
            
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
    
    private func checkForMatch() {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.selectedCards.count == 2 else {
                self.isProcessing = false
                return
            }
            
            let card1 = self.selectedCards[0]
            let card2 = self.selectedCards[1]
            
            self.gameStats.moves += 1
            
            if card1.shapeType == card2.shapeType {
                // Match found
                self.handleMatch(card1: card1, card2: card2)
            } else {
                // No match
                self.handleNoMatch(card1: card1, card2: card2)
            }
            
            self.selectedCards.removeAll()
            self.isProcessing = false
            self.checkGameCompletion()
        }
    }
    
    private func handleMatch(card1: ShapeCard, card2: ShapeCard) {
        if let index1 = cards.firstIndex(where: { $0.id == card1.id }),
           let index2 = cards.firstIndex(where: { $0.id == card2.id }) {
            
            cards[index1].isMatched = true
            cards[index2].isMatched = true
            
            gameStats.matchedPairs += 1
            gameStats.score += 150 // Base score for shapes
        }
    }
    
    private func handleNoMatch(card1: ShapeCard, card2: ShapeCard) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let index1 = self.cards.firstIndex(where: { $0.id == card1.id }),
               let index2 = self.cards.firstIndex(where: { $0.id == card2.id }) {
                
                self.cards[index1].isFaceUp = false
                self.cards[index2].isFaceUp = false
            }
        }
    }
    
    private func handleJokerCard(_ card: ShapeCard) {
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
    }
    
    deinit {
        timer?.invalidate()
    }
}
