import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var playerData: PlayerData

    var body: some View {
        VStack(spacing: 15) {
            Text(playerData.playerAvatar)
                .font(.system(size: 80))
            Text(playerData.playerName)
                .font(.title)

            Divider()

            Text("Score History")
                .font(.headline)

            ScrollView {
                ForEach(playerData.scores.reversed()) { score in
                    HStack {
                        Text(score.gameName)
                        Spacer()
                        Text("L\(score.level)")
                        Spacer()
                        Text("\(score.score) pts")
                        Spacer()
                        Text(score.date, style: .date)
                    }
                    .padding(.horizontal)
                }
            }
            Spacer()
        }
        .padding()
    }
}
