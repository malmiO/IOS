//
//  NavigationManager.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    enum Screen {
        case splash
        case login
        case register
        case home
        case profile
        case memoryMatchLevels
        case gameView(GameViewModel)
        case shapeMatchLevels         
        case shapeGameView(ShapeGameViewModel)
    }
    
    @Published var currentScreen: Screen = .splash
    
    func navigateTo(_ screen: Screen) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }
    }
}
