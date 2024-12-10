//
//  Place.swift
//  ReserveIt
//
//  Created by Julian Niemann on 18.07.24.
//

import Foundation
import CoreLocation

struct PlacesApiResponse: Codable {
    let results: [Place]
}

struct Place: Codable {
    let place_id: String
    let name: String
    let geometry: Geometry
    let vicinity: String?
    let rating: Double?
    let user_ratings_total: Int?
    let photos: [Photo]?
    let opening_hours: OpeningHours?
    let types: [String]?
    let icon: String?
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: CLLocationDegrees
    let lng: CLLocationDegrees
}

struct Photo: Codable {
    let photo_reference: String
    let width: Int
    let height: Int
}

struct OpeningHours: Codable {
    let open_now: Bool?
    let weekday_text: [String]?
}
