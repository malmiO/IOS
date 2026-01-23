//
//  HomeView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP242P-74 on 2026-01-23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    Text("🎮 Game Hub")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)

                    // Game cards
                    VStack(spacing: 15) {
                        NavigationLink {
                            LevelSelectionView()  // First game
                        } label: {
                            GameCard(title: "Color Matching Game", icon: "paintpalette.fill", color: .blue)
                        }

                        NavigationLink {
                            ColorPairsLevelMapView()  // Second game
                        } label: {
                            GameCard(title: "Color Targets", icon: "target", color: .orange)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
        }
    }
}

struct GameCard: View {
    let title: String
    let icon: String
    var color: Color = .blue

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.white)

            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .background(color)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}


