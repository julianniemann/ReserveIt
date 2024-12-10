//
//  RatingViewModel.swift
//  ReserveIt
//
//  Created by Julian Niemann on 13.08.24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// ViewModel responsible for managing user ratings.
class RatingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// List of ratings submitted by the current user.
    @Published var ratings: [Rating] = []
    
    // MARK: - Private Properties
    
    /// Firestore database instance.
    private let db = Firestore.firestore()
    
    /// Current authenticated user.
    private var user: User? {
        return Auth.auth().currentUser
    }
    
    // MARK: - Public Methods
    
    /// Loads ratings submitted by the current user from Firestore.
    func loadUserRatings() {
        guard let user = user else {
            print("User is not logged in")
            return
        }
        
        db.collection("ratings")
            .whereField("userId", isEqualTo: user.uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching ratings: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No ratings found")
                    return
                }
                
                self?.ratings = documents.compactMap { document -> Rating? in
                    try? document.data(as: Rating.self)
                }
            }
    }
    
    /// Writes a new rating to Firestore.
    /// - Parameters:
    ///   - placeId: Identifier of the place being rated.
    ///   - placeName: Name of the place being rated.
    ///   - stars: Number of stars given in the rating.
    ///   - text: Textual review accompanying the rating.
    func writeRating(for placeId: String, placeName: String, stars: Int, text: String) {
        guard let user = user else {
            print("User is not logged in")
            return
        }
        
        let rating = Rating(
            userId: user.uid,
            placeId: placeId,
            placeName: placeName,
            stars: stars,
            text: text
        )
        
        let ratingId = UUID().uuidString
        do {
            try db.collection("ratings").document(ratingId).setData(from: rating)
            print("Rating successfully written!:\(rating)")
        } catch {
            print("Error writing rating: \(error)")
        }
    }
    
    /// Deletes a rating from Firestore.
    /// - Parameter rating: The rating to be deleted.ß
    func deleteRating(_ rating: Rating) {
        guard let id = rating.id else {
            print("Rating ID not found")
            return
        }
        
        db.collection("ratings").document(id).delete { error in
            if let error = error {
                print("Error deleting rating: \(error)")
            } else {
                print("Rating successfully deleted!")
            }
        }
    }
}
