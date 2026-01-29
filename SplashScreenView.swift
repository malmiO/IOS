//
//  SplashScreenView.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App Logo/Icon
                Image(systemName: "gamecontroller.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                
                // App Name
                Text("GameSphere")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Tagline
                Text("Your Gaming Universe")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
            .scaleEffect(isActive ? 0.9 : 1.0)
            .opacity(isActive ? 0 : 1)
        }
        .onAppear {
            // Animate and navigate after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigationManager.navigateTo(.login)
                }
            }
        }
    }
}
