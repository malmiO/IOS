//
//  Tile.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP24.2P-074 on 2026-01-13.
//

// This is only one square
import SwiftUI

struct Tile: Identifiable {
    let id = UUID()
    let color: Color
    var isFlipped = false
    var isMatched = false
    var isJoker = false
}


