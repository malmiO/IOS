//
//  ProfileView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP242P-74 on 2026-01-23.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("playerName") private var playerName: String = "Player 1"
    @AppStorage("gamesPlayed") private var gamesPlayed: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 50)

                Text(playerName)
                    .font(.largeTitle)
                    .bold()

                VStack(spacing: 15) {
                    HStack {
                        Text("Games Played:")
                        Spacer()
                        Text("\(gamesPlayed)")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    HStack {
                        Text("Levels Completed:")
                        Spacer()
                        Text("—") 
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}