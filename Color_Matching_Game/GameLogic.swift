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

    // Generate tiles uniquely 
    static func generateTiles(gridSize: Int, colors: [Color]) -> [Tile] {
        let totalTiles = gridSize * gridSize
        let pairCount = totalTiles / 2 // floor division
        let selectedColors = colors.shuffled().prefix(pairCount)
        
        var tiles: [Tile] = []
        
        // create pairs
        for color in selectedColors {
            tiles.append(Tile(color: color))
            tiles.append(Tile(color: color))
        }
        
        // if totalTiles is odd, add 1 extra tile as Joker
        if totalTiles % 2 != 0 {
            let jokerTile = Tile(color: .purple, isJoker: true)
            tiles.append(jokerTile)
        }
        
        tiles.shuffle()
        return tiles
    }

    // Check if two selected tiles match
    static func isMatch(_ tiles: [Tile], _ selectedIndexes: [Int]) -> Bool {
        let first = selectedIndexes[0]
        let second = selectedIndexes[1]
        return tiles[first].color == tiles[second].color
    }
}


