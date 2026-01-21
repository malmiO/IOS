import SwiftUI

struct GameScore: Identifiable, Codable {
    let id = UUID()
    let gameName: String
    let level: Int
    let score: Int
    let date: Date
}

class PlayerData: ObservableObject {
    @AppStorage("playerName") var playerName: String = ""
    @AppStorage("playerAvatar") var playerAvatar: String = "🙂"
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    @Published var scores: [GameScore] = [] {
        didSet {
            saveScores()
        }
    }

    init() {
        loadScores()
    }
    
    func addScore(_ score: GameScore) {
        scores.append(score)
    }
    
    // Persistence using UserDefaults
    private func saveScores() {
        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: "gameScores")
        }
    }
    
    private func loadScores() {
        if let data = UserDefaults.standard.data(forKey: "gameScores"),
           let saved = try? JSONDecoder().decode([GameScore].self, from: data) {
            self.scores = saved
        }
    }
}
