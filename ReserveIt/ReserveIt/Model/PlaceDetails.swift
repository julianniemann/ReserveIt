//
//  PlaceDetails.swift
//  ReserveIt
//
//  Created by Julian Niemann on 18.07.24.
//

import Foundation

struct PlaceDetailsApiResponse: Codable {
    let result: PlaceDetails
}

struct PlaceDetails: Codable {
    let place_id: String
    let name: String
    let formatted_address: String?
    let formatted_phone_number: String?
    let international_phone_number: String?
    let website: String?
    let rating: Double?
    let user_ratings_total: Int?
    let photos: [Photo]?
    let opening_hours: OpeningHours?
    let reviews: [Review]?
    let price_level: Int?
}

struct Review: Codable {
    let author_name: String
    let rating: Int
    let text: String
    let time: Int
}
