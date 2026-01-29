//
//  RegiatrationView.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var nickname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 40)
                    
                    // Registration Form
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
                        
                        // Nickname Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nickname")
                                .font(.headline)
                            
                            TextField("Choose a nickname", text: $nickname)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 5)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                            
                            SecureField("Enter password (min. 6 characters)", text: $password)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 5)
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                            
                            SecureField("Re-enter password", text: $confirmPassword)
                                .textContentType(.newPassword)
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
                        
                        // Register Button
                        Button(action: {
                            registerUser()
                        }) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Register")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(authViewModel.isLoading)
                        
                        // Back to Login
                        Button("Already have an account? Login") {
                            navigationManager.navigateTo(.login)
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func registerUser() {
        guard !email.isEmpty, !nickname.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            authViewModel.errorMessage = "Please fill in all fields"
            return
        }
        
        authViewModel.register(
            email: email,
            nickname: nickname,
            password: password,
            confirmPassword: confirmPassword
        ) { success in
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
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(NavigationManager())
            .environmentObject(AuthViewModel())
    }
}
