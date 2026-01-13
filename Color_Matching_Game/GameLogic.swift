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

    static func startGame(colors: [Color]) -> [Tile] {
        colors.flatMap { [Tile(color: $0), Tile(color: $0)] }.shuffled()
    }

    static func isMatch(_ tiles: [Tile], _ selected: [Int]) -> Bool {
        let first = selected[0]
        let second = selected[1]
        return tiles[first].color == tiles[second].color
    }
}

