//
//  Color_Matching_GameApp.swift
//  Color_Matching_Game
//
//  Created by COBSCCOMP24.2P-074 on 2026-01-13.
//

import SwiftUI

@main
struct Color_Matching_GameApp: App {
    var body: some Scene {
        WindowGroup {
            if playerData.hasOnboarded {
                MainTabView()
                    .environmentObject(playerData)
            } else {
                SplashView()
                    .environmentObject(playerData)
            }
        }
    }
}
