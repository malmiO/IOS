import SwiftUI

struct SplashView: View {

    @EnvironmentObject var playerData: PlayerData

    @State private var name: String = ""
    @State private var selectedAvatar: String = "🙂"

    let avatars = ["🙂", "😎", "🧑‍🚀", "👻", "🐱", "🐶", "🦊", "🐼"]

    var body: some View {
        VStack(spacing: 25) {

            Spacer()

            Text("🎮 HueQuest")
                .font(.largeTitle)
                .bold()

            Text("Enter your name")
                .font(.headline)

            TextField("Player Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Text("Choose your avatar")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
                ForEach(avatars, id: \.self) { avatar in
                    Text(avatar)
                        .font(.largeTitle)
                        .padding()
                        .background(
                            Circle()
                                .fill(selectedAvatar == avatar ? Color.blue.opacity(0.3) : Color.clear)
                        )
                        .onTapGesture {
                            selectedAvatar = avatar
                        }
                }
            }

            Button(action: startGame) {
                Text("Start Playing")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(name.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(name.isEmpty)

            Spacer()
        }
        .padding()
    }

    func startGame() {
        playerData.playerName = name
        playerData.playerAvatar = selectedAvatar
        playerData.hasOnboarded = true
    }
}
