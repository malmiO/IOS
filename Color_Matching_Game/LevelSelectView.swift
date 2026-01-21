import SwiftUI

struct LevelSelectView: View {
    let gameName: String
    let levels = [1, 2, 3] 

    var body: some View {
        VStack(spacing: 20) {
            Text("\(gameName) - Select Level")
                .font(.title)
                .bold()
                .padding(.top)

            ForEach(levels, id: \.self) { level in
                NavigationLink(destination: GamePlayView(level: level)) {
                    Text("Level \(level)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                }
            }

            Spacer()
        }
        .navigationBarTitle("Levels", displayMode: .inline)
    }
}
