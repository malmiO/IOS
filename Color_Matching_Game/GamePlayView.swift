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

    var gridSize: Int { GameLogic.levelToGrid(level) }

    var body: some View {
        VStack(spacing: 15) {

            // Header
            HStack {
                Text("Level \(level)").bold()
                Spacer()
                Text("Clicks: \(clickCount)").bold()
                Spacer()
                Text("\(secondsElapsed)s")
                    .bold()
                    .padding(6)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                    .animation(.easeInOut, value: secondsElapsed)
            }
            .padding(.horizontal)

            // Tiles Grid with Flip Animation
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: gridSize), spacing: 10) {
                ForEach(tiles.indices, id: \.self) { index in
                    ZStack {
                        // Back
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 50)
                            .cornerRadius(8)
                            .opacity(tiles[index].isFlipped ? 0 : 1)

                        // Front
                        Rectangle()
                            .fill(tiles[index].color)
                            .frame(height: 50)
                            .cornerRadius(8)
                            .overlay(
                                tiles[index].isJoker ? Text("🃏").font(.largeTitle) : nil
                            )
                            .opacity(tiles[index].isFlipped ? 1 : 0)
                    }
                    .rotation3DEffect(
                        .degrees(tiles[index].isFlipped ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    .scaleEffect(selectedIndexes.contains(index) ? 1.05 : 1)
                    .animation(.easeInOut(duration: 0.4), value: tiles[index].isFlipped)
                    .onTapGesture {
                        withAnimation(.spring()) { tileTapped(index) }
                    }
                }
            }
            .padding(.horizontal)

            // Restart Button
            Button(action: startGame) {
                Text("Restart")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.top)

            // Success Message
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

    // Game Functions

    func startGame() {
        tiles = GameLogic.startGame(level: level, colors: colors)
        selectedIndexes.removeAll()
        clickCount = 0
        secondsElapsed = 0
        successMessage = ""
        timerRunning = true
    }

    func tileTapped(_ index: Int) {
        guard !tiles[index].isFlipped && !tiles[index].isMatched && selectedIndexes.count < 2 else { return }

        GameLogic.flipTile(&tiles, at: index)
        selectedIndexes.append(index)
        clickCount += 1

        // Joker tile logic
        if tiles[index].isJoker {
            successMessage = "🎉 You found the Joker!"
            timerRunning = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { startGame() }
            return
        }

        // Normal match check
        if selectedIndexes.count == 2 {
            if GameLogic.isMatch(tiles, selectedIndexes) {
                GameLogic.setMatched(&tiles, indexes: selectedIndexes)
                selectedIndexes.removeAll()
                checkWin()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    for i in selectedIndexes { GameLogic.flipTile(&tiles, at: i) }
                    selectedIndexes.removeAll()
                }
            }
        }
    }

    func checkWin() {
        if GameLogic.checkWin(tiles: tiles) {
            timerRunning = false
            successMessage = "🎉 You matched all colors!"

            // Calculate score
            let score = GameLogic.calculateScore(clicks: clickCount, time: secondsElapsed)
            let gameScore = GameScore(gameName: "Color Matching", level: level, score: score, date: Date())
            playerData.addScore(gameScore)
        }
    }

    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timerRunning {
                withAnimation(.linear(duration: 0.3)) { secondsElapsed += 1 }
            } else {
                timer.invalidate()
            }
        }
    }
}
