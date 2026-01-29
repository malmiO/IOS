//
//  HomeGameModel.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

// Separate model for home screen games to avoid conflict
struct HomeGame: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}
