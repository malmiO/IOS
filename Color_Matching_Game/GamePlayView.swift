import SwiftUI

struct GamePlayView: View {

    let level: Int
    @EnvironmentObject var playerData: PlayerData

    @State private var tiles: [Tile] = []
    @State private var selectedIndexes: [Int] = []
    @State private var clickCount = 0
    @State private var successMessage = ""
    @State private var secondsElapsed = 0
    @State private var timerRunning = false

    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .pink, .cyan, .mint, .brown, .teal, .indigo, .purple, .gray]

    var gridSize: Int {
        switch level {
        case 1: return 3
        case 2: return 5
        case 3: return 7
        default: return 3
        }
    }

    var body: some View {
        VStack(spacing: 15) {
            // Header
            HStack {
                Text("Level \(level)")
                Spacer()
                Text("Clicks: \(clickCount)")
                Spacer()
                Text("Time: \(secondsElapsed)s")
            }
            .padding(.horizontal)

            // Tiles Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridSize), spacing: 10) {
                ForEach(tiles.indices, id: \.self) { index in
                    ZStack {
                        Rectangle()
                            .fill(tiles[index].isFlipped || tiles[index].isMatched ? tiles[index].color : Color.gray)
                            .frame(height: 50)
                            .cornerRadius(8)

                        if tiles[index].isFlipped {
                            Text(tiles[index].isJoker ? "🃏" : "")
                                .font(.largeTitle)
                        }
                    }
                    .onTapGesture { tileTapped(index) }
                }
            }
            .padding(.horizontal)

            // Restart Button
            Button("Restart") { startGame() }
                .padding(.top)

            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
                    .bold()
                    .padding(.top, 5)
            }

            Spacer()
        }
        .onAppear {
            startGame()
            startTimer()
        }
        .navigationBarTitle("Color Matching", displayMode: .inline)
    }

    // Game Logic
    func startGame() {
        let totalTiles = gridSize * gridSize
        let pairCount = totalTiles / 2
        let selectedColors = colors.shuffled().prefix(pairCount)

        var newTiles: [Tile] = []
        for color in selectedColors {
            newTiles.append(Tile(color: color))
            newTiles.append(Tile(color: color))
        }

        if totalTiles % 2 != 0 { newTiles.append(Tile(color: .purple, isJoker: true)) }

        newTiles.shuffle()
        tiles = newTiles
        selectedIndexes.removeAll()
        clickCount = 0
        secondsElapsed = 0
        successMessage = ""
        timerRunning = true
    }

    func tileTapped(_ index: Int) {
        guard !tiles[index].isFlipped && !tiles[index].isMatched && selectedIndexes.count < 2 else { return }

        tiles[index].isFlipped = true
        selectedIndexes.append(index)
        clickCount += 1

        if tiles[index].isJoker {
            successMessage = "😜 Fool ! you click the Joker!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { startGame() }
            return
        }

        if selectedIndexes.count == 2 {
            let first = selectedIndexes[0]
            let second = selectedIndexes[1]

            if tiles[first].color == tiles[second].color {
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
        if tiles.allSatisfy({ $0.isMatched || $0.isJoker }) {
            successMessage = "🎉 You matched all colors!"
            timerRunning = false

            // Calculate score (example)
            let score = max(1000 - (clickCount * 5 + secondsElapsed * 2), 0)
            let gameScore = GameScore(gameName: "Color Matching", level: level, score: score, date: Date())
            playerData.addScore(gameScore)
        }
    }

    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timerRunning { secondsElapsed += 1 }
            else { timer.invalidate() }
        }
    }
}
