//
//  SplashView.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP242P-74 on 2026-01-23.
//

import SwiftUI

struct SplashView: View {
    @State private var navigate = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("🎨 ")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("Game Hub")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                

                Text("Train your brain with colors!")
                    .foregroundColor(.gray)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    navigate = true
                }
            }
            .navigationDestination(isPresented: $navigate) {
                MainView()
            }
        }
    }
}

#Preview {
    SplashView()
}
