//
//  HomeView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP242P-74 on 2026-01-17.
//

import SwiftUI

struct HomeView: View {

    @State private var selectedLevel = 1
    @State private var startGame = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {

                Spacer()

                Text("🎨 Color Matching Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Test your memory before time runs out!")
                    .font(.headline)
                    .foregroundColor(.gray)

                VStack(spacing: 20) {
                    Text("Select Level")
                        .font(.headline)

                    levelButton(level: 1, title: "Easy")
                    levelButton(level: 2, title: "Medium")
                    levelButton(level: 3, title: "Hard")
                }
                .padding(.horizontal)

                NavigationLink(
                    destination: ContentView(currentLevel: selectedLevel),
                    isActive: $startGame
                ) {
                    EmptyView()
                }

                Button {
                    startGame = true
                } label: {
                    Text("Start Game")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedLevel == 0 ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()

                Text("⏱ Beat the timer. 🃏 Avoid the Joker.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }

    // MARK: - Level Button
    @ViewBuilder
    func levelButton(level: Int, title: String) -> some View {
        Button {
            selectedLevel = level
        } label: {
            HStack {
                Text("Level \(level)")
                    .fontWeight(.bold)

                Spacer()

                Text(title)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                selectedLevel == level ? Color.green.opacity(0.8) : Color.gray.opacity(0.3)
            )
            .foregroundColor(.black)
            .cornerRadius(10)
        }
    }
}

#Preview {
    HomeView()
}
