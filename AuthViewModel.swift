//
//  AuthViewModel.swift
//  GameHubApp
//
//  Created by COBSCCOMP242P-74 on 2026-01-29.
//

import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    struct User {
        let email: String
        let nickname: String
        let userId: String
    }
    
    init() {
        checkCurrentUser()
    }
    
    // MARK: - Firebase Authentication Methods
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                if let user = result?.user {
                    // Get the nickname from email (everything before @)
                    let nickname = email.components(separatedBy: "@").first ?? "Player"
                    
                    // Check if we have a stored nickname for this user
                    self?.retrieveNicknameForUser(email: email, userId: user.uid) { storedNickname in
                        self?.currentUser = User(
                            email: email,
                            nickname: storedNickname ?? nickname,
                            userId: user.uid
                        )
                        completion(true)
                    }
                }
            }
        }
    }
    
    func register(email: String, nickname: String, password: String, confirmPassword: String, completion: @escaping (Bool) -> Void) {
        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            completion(false)
            return
        }
        
        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            completion(false)
            return
        }
        
        // Validate password strength
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            completion(false)
            return
        }
        
        // Validate nickname
        guard !nickname.isEmpty else {
            errorMessage = "Nickname cannot be empty"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                if let user = result?.user {
                    // Store the nickname in UserDefaults
                    self?.storeNicknameForUser(email: email, nickname: nickname, userId: user.uid)
                    
                    self?.currentUser = User(
                        email: email,
                        nickname: nickname,
                        userId: user.uid
                    )
                    completion(true)
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }
    
    private func checkCurrentUser() {
        if let user = Auth.auth().currentUser {
            let email = user.email ?? ""
            let userId = user.uid
            
            // Try to retrieve stored nickname
            retrieveNicknameForUser(email: email, userId: userId) { storedNickname in
                let nickname = storedNickname ?? email.components(separatedBy: "@").first ?? "Player"
                
                self.currentUser = User(
                    email: email,
                    nickname: nickname,
                    userId: userId
                )
            }
        }
    }
    
    // MARK: - Nickname Storage (Using UserDefaults for simplicity)
    
    private func storeNicknameForUser(email: String, nickname: String, userId: String) {
        let userDefaults = UserDefaults.standard
        
        // Store by email (for lookup when user logs in with email)
        userDefaults.set(nickname, forKey: "nickname_\(email)")
        
        // Also store by userId (for lookup when app restarts)
        userDefaults.set(nickname, forKey: "nickname_userId_\(userId)")
    }
    
    private func retrieveNicknameForUser(email: String, userId: String, completion: @escaping (String?) -> Void) {
        let userDefaults = UserDefaults.standard
        
        // First try to get by userId (more reliable)
        if let nickname = userDefaults.string(forKey: "nickname_userId_\(userId)") {
            completion(nickname)
            return
        }
        
        // If not found by userId, try by email
        if let nickname = userDefaults.string(forKey: "nickname_\(email)") {
            completion(nickname)
            return
        }
        
        completion(nil)
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
