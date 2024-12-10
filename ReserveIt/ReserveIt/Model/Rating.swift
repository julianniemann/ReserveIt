//
//  Rating.swift
//  ReserveIt
//
//  Created by Julian Niemann on 13.08.24.
//

import Foundation
import FirebaseFirestoreSwift

struct Rating: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var placeId: String
    var placeName: String  
    var stars: Int
    var text: String
    var createdAt: Date
    
    init(userId: String, placeId: String, placeName: String, stars: Int, text: String) {
        self.userId = userId
        self.placeId = placeId
        self.placeName = placeName
        self.stars = stars
        self.text = text
        self.createdAt = Date()
    }
}
