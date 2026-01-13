//
//  ContentView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP24.2P-074 on 2026-01-13.
//

import SwiftUI

struct ContentView: View {

    @State private var tiles: [Tile] = []
    @State private var selectedIndexes: [Int] = []
    @State private var clickCount = 0
    @State private var successMessage = ""

    let colors: [Color] = [.red, .blue, .green]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 20) {

            Text("Color Matching Game")
                .font(.largeTitle)
                .bold()

            Text("Clicks: \(clickCount)")
                .font(.headline)
                .foregroundColor(.gray)

            if !successMessage.isEmpty {
                Text(successMessage)
                    .font(.title2)
                    .foregroundColor(.green)
                    .bold()
                    .padding(.top, 5)
            }

            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(tiles.indices, id: \.self) { index in
                    Rectangle()
                        .fill(
                            tiles[index].isFlipped || tiles[index].isMatched
                            ? tiles[index].color
                            : Color.gray
                        )
                        .frame(height: 100)
                        .cornerRadius(10)
                        .onTapGesture {
                            tileTapped(index)
                        }
                }
            }

            Button("Restart Game") {
                startGame()
            }
        }
        .padding()
        .onAppear {
            startGame()
        }
    }

    // UI

    func startGame() {
        tiles = GameLogic.startGame(colors: colors)
        selectedIndexes.removeAll()
        clickCount = 0
        successMessage = ""
    }

    func tileTapped(_ index: Int) {
        // Ignore already flipped or matched tiles
        if tiles[index].isFlipped || tiles[index].isMatched { return }
        if selectedIndexes.count == 2 { return }

        tiles[index].isFlipped = true
        selectedIndexes.append(index)
        clickCount += 1

        if selectedIndexes.count == 2 {
            let first = selectedIndexes[0]
            let second = selectedIndexes[1]

            if GameLogic.isMatch(tiles, selectedIndexes) {
                tiles[first].isMatched = true
                tiles[second].isMatched = true
                selectedIndexes.removeAll()
                
                checkWin()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    tiles[first].isFlipped = false
                    tiles[second].isFlipped = false
                    selectedIndexes.removeAll()
                }
            }
        }
    }

    func checkWin() {
        if tiles.allSatisfy({ $0.isMatched }) {
            successMessage = "Congratulations! You matched all colors!"
        }
    }
}


#Preview {
    ContentView()
}

