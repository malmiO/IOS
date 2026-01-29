//
//  GameModels.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import Foundation
import SwiftUI

// MARK: - Memory Match Game Models

enum GameLevel: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var gridSize: Int {
        switch self {
        case .easy: return 3
        case .medium: return 5
        case .hard: return 7
        }
    }
    
    var totalCards: Int {
        let total = gridSize * gridSize
        return total % 2 == 0 ? total : total - 1
    }
    
    var pairsCount: Int {
        return totalCards / 2
    }
    
    var jokerCount: Int {
        return 1
    }
}

// This is the Memory Match game card (NOT the same as home screen card)
struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let color: Color
    let originalColor: Color
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    var isJoker: Bool = false
    var index: Int
    
    static func == (lhs: MemoryCard, rhs: MemoryCard) -> Bool {
        lhs.id == rhs.id
    }
}

enum GameState {
    case notStarted
    case playing
    case paused
    case gameOver
    case won
    case jokerRevealed
}

struct GameStats: Codable {
    var moves: Int = 0
    var matchedPairs: Int = 0
    var timeSpent: TimeInterval = 0
    var score: Int = 0
    var jokerFound: Bool = false
    var gameCompleted: Bool = false
}

// For Firebase storage
struct GameSession: Codable {
    var id: String = UUID().uuidString
    var userId: String
    var userEmail: String
    var userNickname: String
    var level: GameLevel
    var startTime: Date
    var endTime: Date?
    var stats: GameStats
    var deviceInfo: String
    var platform: String = "iOS"
    
    var duration: TimeInterval {
        return (endTime ?? Date()).timeIntervalSince(startTime)
    }
}
