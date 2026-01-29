//
//  GameHubAppApp.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct GameSphereApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var navigationManager = NavigationManager()
    
    init() {
        FirebaseApp.configure()
        
        // Optional: Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(navigationManager)
        }
    }
}
