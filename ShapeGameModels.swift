//
//  ShapeGameModels.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import Foundation
import SwiftUI

// MARK: - Shape Types
enum ShapeType: String, CaseIterable, Codable {
    case circle = "Circle"
    case square = "Square"
    case triangle = "Triangle"
    case rectangle = "Rectangle"
    case diamond = "Diamond"
    case star = "Star"
    case heart = "Heart"
    case pentagon = "Pentagon"
    case hexagon = "Hexagon"
    case octagon = "Octagon"
    
    var systemImage: String {
        switch self {
        case .circle: return "circle.fill"
        case .square: return "square.fill"
        case .triangle: return "triangle.fill"
        case .rectangle: return "rectangle.fill"
        case .diamond: return "diamond.fill"
        case .star: return "star.fill"
        case .heart: return "heart.fill"
        case .pentagon: return "pentagon.fill"
        case .hexagon: return "hexagon.fill"
        case .octagon: return "octagon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .circle: return .red
        case .square: return .blue
        case .triangle: return .green
        case .rectangle: return .yellow
        case .diamond: return .orange
        case .star: return .purple
        case .heart: return .pink
        case .pentagon: return .cyan
        case .hexagon: return .mint
        case .octagon: return .teal
        }
    }
}

// MARK: - Shape Card
struct ShapeCard: Identifiable, Equatable {
    let id = UUID()
    let shapeType: ShapeType
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    var isJoker: Bool = false
    var index: Int
    
    static func == (lhs: ShapeCard, rhs: ShapeCard) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Shape Game Session
struct ShapeGameSession: Codable {
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
