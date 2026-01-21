//
//  GameLogic.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP24.2P-074 on 2026-01-13.
//

// only for functions

// game logics

import SwiftUI

struct GameLogic {

    static func generateTiles(gridSize: Int, colors: [Color]) -> [Tile] {
        let totalTiles = gridSize * gridSize
        let pairCount = totalTiles / 2
        
        var tiles: [Tile] = []
        let selectedColors = colors.shuffled().prefix(pairCount)
        
        for color in selectedColors {
            tiles.append(Tile(color: color))
            tiles.append(Tile(color: color))
        }
        
        if totalTiles % 2 != 0 {
            tiles.append(Tile(color: .purple, isJoker: true))
        }
        
        tiles.shuffle()
        return tiles
    }
    
    static func levelToGrid(_ level: Int) -> Int {
        switch level {
        case 1: return 3
        case 2: return 5
        case 3: return 7
        default: return 3
        }
    }
    
    static func startGame(level: Int, colors: [Color]) -> [Tile] {
        let gridSize = levelToGrid(level)
        return generateTiles(gridSize: gridSize, colors: colors)
    }
    
    static func isMatch(_ tiles: [Tile], _ selectedIndexes: [Int]) -> Bool {
        let first = selectedIndexes[0]
        let second = selectedIndexes[1]
        return tiles[first].color == tiles[second].color
    }
    
    static func checkWin(tiles: [Tile]) -> Bool {
        tiles.allSatisfy { $0.isMatched || $0.isJoker }
    }
    
    static func calculateScore(clicks: Int, time: Int) -> Int {
        max(1000 - (clicks * 5 + time * 2), 0)
    }
    
    static func flipTile(_ tiles: inout [Tile], at index: Int) {
        tiles[index].isFlipped.toggle()
    }
    
    static func setMatched(_ tiles: inout [Tile], indexes: [Int]) {
        for i in indexes { tiles[i].isMatched = true }
    }
}
