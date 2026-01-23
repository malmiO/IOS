//
//  ColorPairsLevelMapView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP242P-74 on 2026-01-23.
//

import SwiftUI

struct ColorPairsLevelMapView: View {
    @State private var unlockedLevel: Int = 1

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🎯 Color Harvest Levels")
                    .font(.largeTitle)
                    .bold()

                ForEach(1...20, id: \.self) { level in
                    NavigationLink {
                        ColorPairsChallengeView(level: level)
                    } label: {
                        Text("Level \(level)")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(level <= unlockedLevel ? Color.orange : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(level > unlockedLevel)
                }
            }
            .padding()
        }
    }
}
