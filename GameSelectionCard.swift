//
//  GameSelectionCard.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct GameSelectionCard: View {
    let game: HomeGame
    
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
