//
//  ContentView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP24.2P-074 on 2026-01-13.
//

import SwiftUI
import Combine

struct ContentView: View {

    // MARK: - Game State
    let currentLevel: Int
    
    @State private var tiles: [Tile] = []
    @State private var selectedIndexes: [Int] = []

    @State private var clickCount = 0
    @State private var score = 0
    @State private var comboCount = 0

    @State private var timeRemaining = 60
    @State private var movesLeft = 0
    @State private var isGameOver = false
    @State private var successMessage = ""

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Colors
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .pink, .cyan, .mint, .brown, .teal, .indigo, .purple, .gray, .mint, .brown, .pink, .orange, .red, .blue, .green, .yellow, .pink, .cyan, .mint, .brown]


    // MARK: - Level Config
    var gridSize: Int {
        switch currentLevel {
        case 1: return 3
        case 2: return 5
        case 3: return 7
        default: return 3
        }
    }

    var levelTime: Int {
        switch currentLevel {
        case 1: return 50
        case 2: return 80
        case 3: return 100
        default: return 50
        }
    }

    var maxMoves: Int {
        switch currentLevel {
        case 1: return 30
        case 2: return 50
        case 3: return 80
        default: return 30
        }
    }

    // MARK: - UI
    var body: some View {
        VStack(spacing: 15) {

            Text("🎨 Color Matching Game")
                .font(.largeTitle)
                .bold()

            // HUD
            HStack {
                Text("Score: \(score)")
                Spacer()
                Text("Moves: \(movesLeft)")
                    .foregroundColor(movesLeft <= 5 ? .red : .blue)
                Spacer()
                Text("⏱ \(timeRemaining)s")
                    .foregroundColor(timeRemaining <= 10 ? .red : .green)
            }
            .font(.headline)
            .padding(.horizontal)

            if !successMessage.isEmpty {
                Text(successMessage)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.purple)
            }

            // Grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: gridSize),
                spacing: 10
            ) {
                ForEach(tiles.indices, id: \.self) { index in
                    ZStack {
                        Rectangle()
                            .fill(
                                tiles[index].isFlipped || tiles[index].isMatched
                                ? tiles[index].color
                                : Color.gray
                            )
                            .frame(height: 50)
                            .cornerRadius(8)

                        if tiles[index].isFlipped {
                            Text(tiles[index].isJoker ? "🃏" : "")
                                .font(.largeTitle)
                        }
                    }
                    .onTapGesture {
                        tileTapped(index)
                    }
                    .animation(.easeInOut, value: tiles[index].isFlipped)
                }
            }
            .padding()

            Button("Restart Game") {
                startGame()
            }
            .padding(.top)

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.white, .blue.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            startGame()
        }
        .onReceive(timer) { _ in
            guard !isGameOver else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameOver()
            }
        }
    }

    // MARK: - Game Functions

    func startGame() {
        tiles = GameLogic.generateTiles(gridSize: gridSize, colors: colors)

        selectedIndexes.removeAll()
        clickCount = 0
        score = 0
        comboCount = 0
        isGameOver = false
        successMessage = ""
        timeRemaining = levelTime
        movesLeft = maxMoves
    }

    func tileTapped(_ index: Int) {
        if isGameOver { return }
        if tiles[index].isFlipped || tiles[index].isMatched { return }
        if selectedIndexes.count == 2 { return }
        if movesLeft <= 0 {
            gameOver()
            return
        }

        tiles[index].isFlipped = true
        selectedIndexes.append(index)
        clickCount += 1
        movesLeft -= 1

        // Joker
        if tiles[index].isJoker {
            score -= 10
            successMessage = "🃏 Joker! Game Over!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                gameOver()
            }
            return
        }

        // Match Logic
        if selectedIndexes.count == 2 {
            let first = selectedIndexes[0]
            let second = selectedIndexes[1]

            if GameLogic.isMatch(tiles, selectedIndexes) {
                tiles[first].isMatched = true
                tiles[second].isMatched = true

                comboCount += 1
                score += 10 * comboCount
                selectedIndexes.removeAll()

                checkWin()
            } else {
                comboCount = 0
                score -= 2

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    tiles[first].isFlipped = false
                    tiles[second].isFlipped = false
                    selectedIndexes.removeAll()
                }
            }
        }
    }

    func gameOver() {
        isGameOver = true
        successMessage = "💀 Game Over!"

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            startGame()
        }
    }

    func checkWin() {
        if tiles.allSatisfy({ $0.isMatched || $0.isJoker }) {
            let stars: String

            if movesLeft > maxMoves / 2 {
                stars = "⭐⭐⭐"
            } else if movesLeft > maxMoves / 4 {
                stars = "⭐⭐"
            } else {
                stars = "⭐"
            }

            successMessage = "🎉 You Win! \(stars)"
            isGameOver = true
        }
    }
}

#Preview {
    ContentView(currentLevel: 1)
}
