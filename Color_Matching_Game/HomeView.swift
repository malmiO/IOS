import SwiftUI

struct HomeView: View {
    @EnvironmentObject var playerData: PlayerData

    let games = [
        ("Color Matching", "🎨")
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text(playerData.playerAvatar).font(.largeTitle)
                    Spacer()
                    Text("HueQuest").font(.title).bold()
                    Spacer()
                }
                .padding(.horizontal)
                
                Text("Welcome, \(playerData.playerName)!")
                    .font(.title2)
                    .padding(.bottom)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(games, id: \.0) { game in
                            NavigationLink(destination: LevelSelectView(gameName: game.0)) {
                                VStack {
                                    Text(game.1).font(.system(size: 50))
                                    Text(game.0).font(.headline).foregroundColor(.white)
                                }
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .padding(.horizontal, 5)
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}
