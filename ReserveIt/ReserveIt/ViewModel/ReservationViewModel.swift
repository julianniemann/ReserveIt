//
//  ReservationViewModel.swift
//  ReserveIt
//
//  Created by Julian Niemann on 12.08.24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// ViewModel responsible for managing user reservations.
class ReservationViewModel: ObservableObject {
    
    // MARK: - Private Properties
    
    /// Firestore database instance.
    private let db = Firestore.firestore()
    
    /// Current authenticated user.
    private var user: User? {
        return Auth.auth().currentUser
    }
    
    // MARK: - Published Properties
    
    /// List of reservations for the current user.
    @Published var reservations: [Reservation] = []
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel and loads reservations.
    init() {
        loadReservations()
    }
    
    // MARK: - Public Methods
    
    /// Loads reservations from Firestore for the current user.
    func loadReservations() {
        guard let user = user else {
            print("User is not logged in")
            return
        }
        
        db.collection("reservations")
            .whereField("userId", isEqualTo: user.uid)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching reservations: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No reservations found")
                    return
                }
                
                self?.reservations = documents.compactMap { document -> Reservation? in
                    do {
                        let data = try document.data(as: Reservation.self)
                        return data
                    } catch {
                        print("Error decoding reservation: \(error)")
                        return nil
                    }
                }
            }
    }
    
    /// Creates a new reservation in Firestore.
    /// - Parameters:
    ///   - placeId: Identifier of the place for the reservation.
    ///   - placeName: Name of the place.
    ///   - date: Date and time of the reservation.
    ///   - notes: Additional notes for the reservation.
    ///   - numberOfPeople: Number of people for the reservation.
    func createReservation(for placeId: String, placeName: String, date: Date, notes: String, numberOfPeople: Int) {
        guard let user = user else {
            print("User is not logged in")
            return
        }
        
        let reservation = Reservation(
            placeId: placeId,
            placeName: placeName,
            userId: user.uid,
            date: date,
            notes: notes,
            numberOfPeople: numberOfPeople
        )
        
        let reservationId = UUID().uuidString
        db.collection("reservations").document(reservationId).setData([
            "placeId": reservation.placeId,
            "placeName": reservation.placeName,
            "userId": reservation.userId,
            "date": reservation.date,
            "notes": reservation.notes,
            "numberOfPeople": reservation.numberOfPeople,
            "status": reservation.status,
            "createdAt": reservation.createdAt,
            "updatedAt": reservation.updatedAt
        ]) { error in
            if let error = error {
                print("Error saving reservation: \(error)")
            } else {
                print("Reservation successfully created!")
            }
        }
    }
    
    /// Deletes an existing reservation from Firestore.
    /// - Parameter reservation: The reservation to be deleted.
    func deleteReservation(_ reservation: Reservation) {
        guard let id = reservation.id else {
            print("Reservation ID not found")
            return
        }
        
        db.collection("reservations").document(id).delete { error in
            if let error = error {
                print("Error deleting reservation: \(error)")
            } else {
                print("Reservation successfully deleted!")
            }
        }
    }
}
