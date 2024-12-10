//
//  Reservation.swift
//  ReserveIt
//
//  Created by Julian Niemann on 12.08.24.
//

import Foundation
import FirebaseFirestoreSwift

struct Reservation: Codable, Identifiable {
    @DocumentID var id: String?
    var placeId: String
    var placeName: String  
    var userId: String
    var date: Date
    var notes: String
    var numberOfPeople: Int
    var status: String
    var createdAt: Date
    var updatedAt: Date
    
    init(placeId: String, placeName: String, userId: String, date: Date, notes: String, numberOfPeople: Int) {
        self.placeId = placeId
        self.placeName = placeName
        self.userId = userId
        self.date = date
        self.notes = notes
        self.numberOfPeople = numberOfPeople
        self.status = "pending"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
