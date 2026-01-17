//
//  ContentView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP24.2P-074 on 2026-01-13.
//

import SwiftUI
internal import Combine

struct ContentView: View {

    @State private var tiles: [Tile] = []
    @State private var selectedIndexes: [Int] = []
    @State private var clickCount = 0
    @State private var successMessage = ""
    @State var currentLevel = 1
    @State private var timeRemaining = 60
    @State private var isGameOver = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()


    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .pink, .cyan, .mint, .brown, .teal, .indigo, .purple, .gray, .mint, .brown, .pink, .orange, .red, .blue, .green, .yellow, .pink, .cyan, .mint, .brown]

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
        case 1: return 10
        case 2: return 30
        case 3: return 60
        default: return 10
        }
    }


    var body: some View {
        VStack(spacing: 20) {

            Text("Color Matching Game")
                .font(.largeTitle)
                .bold()

            Text("Clicks: \(clickCount)")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Time: \(timeRemaining)s")
                .font(.headline)
                .foregroundColor(timeRemaining <= 10 ? .red : .blue)

            if !successMessage.isEmpty {
                Text(successMessage)
                    .font(.title2)
                    .foregroundColor(.green)
                    .bold()
                    .padding(.top, 5)
            }
            


            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridSize), spacing: 10) {
                            ForEach(tiles.indices, id: \.self) { index in
                                ZStack {
                                    Rectangle()
                                        .fill(tiles[index].isFlipped || tiles[index].isMatched ? tiles[index].color : Color.gray)
                                        .frame(height: 50)
                                        .cornerRadius(8)
                                    
                                    if tiles[index].isFlipped {
                                        // Show joker emoji if tile is joker
                                        Text(tiles[index].isJoker ? "🃏" : "")
                                            .font(.largeTitle)
                                    }
                                }
                                .onTapGesture {
                                    tileTapped(index)
                                }
                            }
                        }
                        .padding(.horizontal)

            Button("Restart Game") {
                startGame()
            }
            .padding(.top, 10)
        }
        
        .onReceive(timer) { _ in
            guard !isGameOver else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameOver()
            }
        }

        
        .padding()
        .onAppear {
            startGame()
        }
    }

    // Game function
    
    func startGame() {
            let totalTiles = gridSize * gridSize
            let pairCount = totalTiles / 2
            
            // Pick random colors for pairs
            let selectedColors = colors.shuffled().prefix(pairCount)

            var newTiles: [Tile] = []
            
            // Create pairs
            for color in selectedColors {
                newTiles.append(Tile(color: color))
                newTiles.append(Tile(color: color))
            }
            
            // If odd total tiles, add a hidden Joker tile
            if totalTiles % 2 != 0 {
                let jokerTile = Tile(color: .purple, isJoker: true)
                newTiles.append(jokerTile)
            }
            
            // Shuffle all tiles
            newTiles.shuffle()
            tiles = newTiles
            
            // Reset state
            selectedIndexes.removeAll()
            clickCount = 0
            successMessage = ""
            isGameOver = false
            timeRemaining = levelTime
        }
        
        func tileTapped(_ index: Int) {
            // Ignore already flipped or matched tiles
            if tiles[index].isFlipped || tiles[index].isMatched { return }
            if selectedIndexes.count == 2 { return }
            
            // Flip the tile
            tiles[index].isFlipped = true
            selectedIndexes.append(index)
            clickCount += 1
            
            // Joker tile clicked
            if tiles[index].isJoker {
                successMessage = " You fool with the Joker! Play again, buddy!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    startGame()
                }
                return
            }
            
            // Normal matching logic
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
            
            if isGameOver { return }
                if tiles[index].isFlipped || tiles[index].isMatched { return }
                if selectedIndexes.count == 2 { return }
        }
        
        func gameOver() {
            isGameOver = true
            successMessage = "⏰ Time’s up! Game Over!"

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                startGame()
            }
        }

        func checkWin() {
            if tiles.allSatisfy({ $0.isMatched || $0.isJoker }) {
                successMessage = " Congratulations! You matched all colors!"
            }
            isGameOver = true
        }
    }

#Preview {
    ContentView()
}

