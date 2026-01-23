//
//  LevelSelectionView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP242P-74 on 2026-01-23.
//

import SwiftUI

struct LevelSelectionView: View {
    var body: some View {
        VStack(spacing: 20) {

            Text("Select Level")
                .font(.largeTitle)
                .bold()

            NavigationLink {
                ContentView(currentLevel: 1)
            } label: {
                LevelButton(title: "Easy", color: .green)
            }

            NavigationLink {
                ContentView(currentLevel: 2)
            } label: {
                LevelButton(title: "Medium", color: .orange)
            }

            NavigationLink {
                ContentView(currentLevel: 3)
            } label: {
                LevelButton(title: "Hard", color: .red)
            }

            Spacer()
        }
        .padding()
    }
}

struct LevelButton: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.title2)
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}
