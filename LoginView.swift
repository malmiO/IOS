//
//  LoginView.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGray6).ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Welcome Back!")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 40)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                            
                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textContentType(.emailAddress)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 5)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                            
                            SecureField("Enter your password", text: $password)
                                .textContentType(.password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 5)
                        }
                        
                        // Error Message
                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Login Button
                        Button(action: {
                            loginUser()
                        }) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Login")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(authViewModel.isLoading)
                        
                        // Register Link
                        Button("Don't have an account? Register") {
                            navigationManager.navigateTo(.register)
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Demo credentials hint
                    VStack(spacing: 5) {
                        Text("For testing:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Use any email & password (≥6 chars)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            authViewModel.errorMessage = "Please fill in all fields"
            return
        }
        
        authViewModel.login(email: email, password: password) { success in
            if success {
                navigationManager.navigateTo(.home)
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(NavigationManager())
            .environmentObject(AuthViewModel())
    }
}
