//
//  GameTypes.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

// MARK: - Memory Match Game Types
enum MemoryMatch {
    struct Card: Identifiable, Equatable {
        let id = UUID()
        let color: Color
        let originalColor: Color
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var isJoker: Bool = false
        var index: Int
        
        static func == (lhs: Card, rhs: Card) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    enum Level: String, CaseIterable, Codable {
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
    }
}

// MARK: - Home Screen Game Types
enum HomeScreen {
    struct Game: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let color: Color
    }
    
    struct Card: View {
        let game: Game
        
        var body: some View {
            VStack(spacing: 15) {
                Image(systemName: game.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text(game.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(minHeight: 150)
            .frame(maxWidth: .infinity)
            .padding()
            .background(game.color)
            .cornerRadius(15)
            .shadow(color: game.color.opacity(0.3), radius: 10, y: 5)
        }
    }
}
