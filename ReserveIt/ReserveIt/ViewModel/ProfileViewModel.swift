//
//  ProfileViewModel.swift
//  ReserveIt
//
//  Created by Julian Niemann on 08.08.24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// ViewModel managing user profile data and interactions.
class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// User's email address.
    @Published var email: String = ""
    
    /// User's display nickname.
    @Published var nickname: String = ""
    
    /// User's phone number.
    @Published var phoneNumber: String = ""
    
    /// User's street address.
    @Published var street: String = ""
    
    /// User's postal code.
    @Published var postalCode: String = ""
    
    /// User's city.
    @Published var city: String = ""
    
    // MARK: - Private Properties
    
    /// Firestore database instance.
    private var db = Firestore.firestore()
    
    /// Current authenticated user.
    private var user: User? {
        return Auth.auth().currentUser
    }
    
    // MARK: - Public Methods
    
    /// Loads the user's profile data from Firestore and updates the published properties.
    func loadProfile() {
        guard let userId = user?.uid else { return }
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }
            
            if let data = snapshot?.data() {
                self.email = data["email"] as? String ?? ""
                self.nickname = data["nickname"] as? String ?? ""
                self.phoneNumber = data["phoneNumber"] as? String ?? ""
                
                let address = data["address"] as? [String: String] ?? [:]
                self.street = address["street"] ?? ""
                self.postalCode = address["postalCode"] ?? ""
                self.city = address["city"] ?? ""
            }
        }
    }
    
    /// Saves the user's profile data to Firestore.
    func saveProfile() {
        guard let userId = user?.uid else { return }
        db.collection("users").document(userId).setData([
            "nickname": nickname,
            "phoneNumber": phoneNumber,
            "address": [
                "street": street,
                "postalCode": postalCode,
                "city": city
            ]
        ]) { error in
            if let error = error {
                print("Error saving user data: \(error)")
            } else {
                print("User data successfully updated!")
            }
        }
    }
}
