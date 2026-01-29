//
//  ContentView.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            switch navigationManager.currentScreen {
            case .splash:
                SplashScreenView()
            case .login:
                LoginView()
            case .register:
                RegistrationView()
            case .home:
                HomeView()
            case .profile:
                ProfileView()
            case .memoryMatchLevels:
                MemoryMatchLevelsView()
            case .gameView(let gameViewModel):
                MemoryMatchGameView(gameViewModel: gameViewModel)
            case .shapeMatchLevels:
                ShapeMatchLevelsView()
            case .shapeGameView(let shapeGameViewModel):
                ShapeMatchingGameView(gameViewModel: shapeGameViewModel)
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationManager())
        .environmentObject(AuthViewModel())
}
