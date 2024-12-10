//
//  AuthenticationViewModel.swift
//  ReserveIt
//
//  Created by Julian Niemann on 08.07.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// ViewModel managing user authentication and Firestore user data.
class AuthenticationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Currently authenticated user, if any.
    @Published private(set) var user: FireUser?
    
    /// Flag indicating user authentication status.
    @Published var isAuthenticated: Bool = false
    
    /// Error message for password mismatches during registration.
    @Published private(set) var passwordError: String?
    
    // MARK: - Computed Properties
    
    /// Returns true if a user is logged in.
    var isUserLoggedIn: Bool {
        self.user != nil
    }
    
    // MARK: - Private Properties
    
    /// Firebase Authentication instance.
    private let firebaseAuthentication = Auth.auth()
    
    /// Firestore instance for user data operations.
    private let firebaseFirestore = Firestore.firestore()
    
    // MARK: - Initialization
    
    init() {
        // Fetch current user data if already signed in.
        if let currentUser = self.firebaseAuthentication.currentUser {
            self.fetchFirestoreUser(withId: currentUser.uid)
        }
    }
    
    // MARK: - Public Methods
    
    /// Logs in a user with email and password.
    /// - Parameters:
    ///   - email: User's email.
    ///   - password: User's password.
    func login(email: String, password: String) {
        firebaseAuthentication.signIn(withEmail: email, password: password) { authResult, error in
            if let error {
                print("Error in login: \(error)")
                return
            }
            
            guard let authResult = authResult, let userEmail = authResult.user.email else {
                print("Authentication result or Email is missing.")
                return
            }
            
            print("Successfully signed in with user-Id \(authResult.user.uid) and email \(userEmail)")
            
            self.fetchFirestoreUser(withId: authResult.user.uid)
            self.isAuthenticated.toggle()
        }
    }
    
    /// Registers a new user.
    /// - Parameters:
    ///   - email: User's email.
    ///   - nickname: User's nickname.
    ///   - password: User's chosen password.
    ///   - passwordCheck: Password confirmation for verification.
    func register(email: String, nickname: String, password: String, passwordCheck: String) {
        guard password == passwordCheck else {
            self.passwordError = "Passwords do not match!"
            return
        }
        
        firebaseAuthentication.createUser(withEmail: email, password: password) { authResult, error in
            if let error {
                print("Error in registration: \(error)")
                return
            }
            
            guard let authResult = authResult, let userEmail = authResult.user.email else {
                print("Authentication result or Email is missing.")
                return
            }
            
            print("Successfully registered with user-Id \(authResult.user.uid) and email \(userEmail)")
            
            self.createFirestoreUser(id: authResult.user.uid, email: email, nickname: nickname)
            self.fetchFirestoreUser(withId: authResult.user.uid)
            self.isAuthenticated.toggle()
        }
    }
    
    /// Signs out the current user.
    func logout() {
        do {
            try firebaseAuthentication.signOut()
            self.user = nil
        } catch {
            print("Error in logout: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Creates a new user document in Firestore.
    /// - Parameters:
    ///   - id: User's unique ID.
    ///   - email: User's email.
    ///   - nickname: User's nickname.
    private func createFirestoreUser(id: String, email: String, nickname: String) {
        let newFireUser = FireUser(id: id, email: email, nickname: nickname, registeredAt: Date())
        
        do {
            try self.firebaseFirestore.collection("users").document(id).setData(from: newFireUser)
        } catch {
            print("Error saving user in Firestore: \(error)")
        }
    }
    
    /// Fetches user data from Firestore.
    /// - Parameter id: User's unique ID.
    private func fetchFirestoreUser(withId id: String) {
        self.firebaseFirestore.collection("users").document(id).getDocument { document, error in
            if let error {
                print("Error fetching user: \(error)")
                return
            }
            
            guard let document else {
                print("Document does not exist.")
                return
            }
            
            do {
                let user = try document.data(as: FireUser.self)
                self.user = user
            } catch {
                print("Could not decode user: \(error)")
            }
        }
    }
}
