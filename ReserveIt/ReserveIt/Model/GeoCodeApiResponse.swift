//
//  GeoCodeApiResponse.swift
//  ReserveIt
//
//  Created by Julian Niemann on 23.07.24.
//

import Foundation
import CoreLocation

struct GeocodeApiResponse: Codable {
    let results: [GeocodeResult]
}

struct GeocodeResult: Codable {
    let geometry: GeocodeGeometry
}

struct GeocodeGeometry: Codable {
    let location: GeocodeLocation
}

struct GeocodeLocation: Codable {
    let lat: Double
    let lng: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
