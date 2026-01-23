//
//  ColorPairsTile.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP242P-74 on 2026-01-23.
//

import SwiftUI

struct ColorPairsTile: Identifiable {
    let id = UUID()
    var color: Color
    var isMatched: Bool = false
    var isSelected: Bool = false
}
