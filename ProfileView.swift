//
//  ProfileView.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                HStack {
                    Text("GameSphere")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if let user = authViewModel.currentUser {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(user.nickname)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
                
                Text("Profile")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 50)
            .padding(.bottom, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Profile Content
            ScrollView {
                VStack(spacing: 30) {
                    // Profile Picture
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    // User Info
                    VStack(spacing: 15) {
                        if let user = authViewModel.currentUser {
                            InfoRow(title: "Nickname", value: user.nickname)
                            InfoRow(title: "Email", value: user.email)
                            InfoRow(title: "User ID", value: user.userId.prefix(8) + "...")
                        }
                        
                        InfoRow(title: "Member Since", value: "Today")
                        InfoRow(title: "Games Played", value: "0")
                        InfoRow(title: "High Score", value: "0")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.1), radius: 5)
                    .padding(.horizontal)
                    
                    // Logout Button
                    Button(action: {
                        authViewModel.logout()
                        navigationManager.navigateTo(.login)
                    }) {
                        Text("Logout")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {
                    navigationManager.navigateTo(.home)
                }) {
                    VStack {
                        Image(systemName: "house")
                            .font(.title2)
                        Text("Home")
                            .font(.caption)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    navigationManager.navigateTo(.profile)
                }) {
                    VStack {
                        Image(systemName: "person.fill")
                            .font(.title2)
                        Text("Profile")
                            .font(.caption)
                    }
                    
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .shadow(color: .gray.opacity(0.1), radius: 5, y: -2)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
}

// Helper view for profile info rows
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
