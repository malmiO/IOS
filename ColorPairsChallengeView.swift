//
//  ColorPairsChallengeView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP242P-74 on 2026-01-23.
//

import SwiftUI

struct ColorPairsChallengeView: View {
    let level: Int

    @State private var tiles: [ColorPairsTile] = []
    @State private var selectedIndexes: [Int] = []
    @State private var clickCount = 0
    @State private var successMessage = ""
    @State private var gridSize = 3
    @State private var targetColors: [Color] = []
    @State private var remainingPairs: [Color: Int] = [:]

    let allColors: [Color] = [.red, .blue, .green, .yellow, .orange, .pink, .cyan, .mint, .brown, .teal, .indigo, .purple, .gray]

    var body: some View {
        VStack(spacing: 20) {
            Text("🎯 Level \(level)")
                .font(.largeTitle)
                .bold()

            HStack {
                ForEach(targetColors, id: \.self) { color in
                    VStack {
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                        Text("\(remainingPairs[color] ?? 0) pairs")
                            .font(.headline)
                    }
                    .padding(5)
                }
            }

            Text("Clicks: \(clickCount)")
                .font(.headline)
                .foregroundColor(.gray)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridSize), spacing: 8) {
                ForEach(tiles.indices, id: \.self) { index in
                    Rectangle()
                        .fill(tiles[index].isMatched ? Color.gray.opacity(0.3) : tiles[index].color)
                        .frame(height: 50)
                        .cornerRadius(8)
                        .overlay(
                            tiles[index].isSelected ? RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 3) : nil
                        )
                        .onTapGesture {
                            tileTapped(index)
                        }
                }
            }
            .padding(.horizontal)

            if !successMessage.isEmpty {
                Text(successMessage)
                    .font(.title2)
                    .foregroundColor(.green)
                    .bold()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            startLevel()
        }
    }

    // MARK: - Game Logic

    func startLevel() {
        clickCount = 0
        successMessage = ""
        selectedIndexes.removeAll()

        // Grid size progression
        switch level {
        case 1...4: gridSize = 3
        case 5...8: gridSize = 4
        case 9...12: gridSize = 5
        case 13...16: gridSize = 6
        case 17...20: gridSize = 7
        default: gridSize = 3
        }

        // Choose 1-3 target colors per level
        targetColors = Array(allColors.shuffled().prefix(min(1 + level / 5, 3)))

        // Initialize pairs
        remainingPairs = [:]
        for color in targetColors {
            remainingPairs[color] = 2 + level / 5
        }

        // Generate initial grid
        tiles = ColorPairsLogic.generateTiles(gridSize: gridSize, colors: allColors, targetColors: targetColors, pairsPerColor: remainingPairs.values.max()!)
    }

    func tileTapped(_ index: Int) {
        if tiles[index].isMatched { return }

        clickCount += 1

        tiles[index].isSelected = true
        selectedIndexes.append(index)

        if selectedIndexes.count == 2 {
            let first = tiles[selectedIndexes[0]]
            let second = tiles[selectedIndexes[1]]

            if first.color == second.color, targetColors.contains(first.color) {
                // Match success
                tiles[selectedIndexes[0]].isMatched = true
                tiles[selectedIndexes[1]].isMatched = true

                remainingPairs[first.color]! -= 1

                if remainingPairs[first.color]! <= 0 {
                    remainingPairs[first.color] = 0
                }

                // Refill grid
                ColorPairsLogic.refillGrid(&tiles, gridSize: gridSize, allColors: allColors, targetColors: targetColors, remainingPairs: remainingPairs)
            }

            // Deselect tiles after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tiles[selectedIndexes[0]].isSelected = false
                tiles[selectedIndexes[1]].isSelected = false
                selectedIndexes.removeAll()
            }
        }

        // Check if level complete
        if remainingPairs.values.allSatisfy({ $0 == 0 }) {
            successMessage = "🎉 Level Completed!"
        }
    }
}
