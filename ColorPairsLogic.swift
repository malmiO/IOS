//
//  ColorPairsLogic.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP242P-74 on 2026-01-23.
//

import SwiftUI

struct ColorPairsLogic {

    /// Generate a grid with guaranteed target tiles
    static func generateTiles(gridSize: Int, colors: [Color], targetColors: [Color], pairsPerColor: Int) -> [ColorPairsTile] {
        let totalTiles = gridSize * gridSize
        var tiles: [ColorPairsTile] = []

        // Add guaranteed tiles for targets
        for color in targetColors {
            for _ in 0..<(pairsPerColor * 2) { // 2 tiles per pair
                tiles.append(ColorPairsTile(color: color))
            }
        }

        // Fill remaining tiles randomly
        while tiles.count < totalTiles {
            tiles.append(ColorPairsTile(color: colors.randomElement()!))
        }

        return tiles.shuffled()
    }

    /// Refill unmatched tiles randomly, ensuring enough target tiles
    static func refillGrid(_ tiles: inout [ColorPairsTile], gridSize: Int, allColors: [Color], targetColors: [Color], remainingPairs: [Color: Int]) {

        for i in tiles.indices {
            if tiles[i].isMatched {
                continue
            }

            // Count how many tiles of this target color are in the grid
            let color = tiles[i].color
            if let targetCount = remainingPairs[color], targetCount > 0 {
                tiles[i].color = color
            } else {
                tiles[i].color = allColors.randomElement()!
            }
        }

        // Shuffle the grid
        tiles.shuffle()
    }
}
