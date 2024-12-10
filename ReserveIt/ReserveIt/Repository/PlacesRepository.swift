//
//  PlacesRepository.swift
//  ReserveIt
//
//  Created by Julian Niemann on 18.07.24.
//

import Foundation
import CoreLocation

/// Repository class for handling API requests related to places.
class PlacesRepository {
    
    // MARK: - Errors
    
    enum ApiError: Error {
        case invalidUrl
        case requestFailed
        case decodingError
    }
    
    // MARK: - Methods
    
    /// Searches for places near a given location with a specific radius and query.
    /// - Parameters:
    ///   - location: The coordinate around which to search for places.
    ///   - radius: The radius (in meters) within which to search.
    ///   - query: The search query (e.g., "restaurant").
    /// - Returns: An array of `Place` objects.
    /// - Throws: An error if the request fails or the URL is invalid.
    func searchPlaces(near location: CLLocationCoordinate2D, radius: Int, query: String) async throws -> [Place] {
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.latitude),\(location.longitude)&radius=\(radius)&keyword=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&key=\(ApiKeys.googleAPIkey)"
        
        guard let url = URL(string: urlString) else {
            throw ApiError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ApiError.requestFailed
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(PlacesApiResponse.self, from: data)
            return apiResponse.results
        } catch {
            throw ApiError.decodingError
        }
    }
    
    /// Fetches details for a specific place by its place ID.
    /// - Parameter placeId: The ID of the place to fetch details for.
    /// - Returns: A `PlaceDetails` object containing detailed information about the place.
    /// - Throws: An error if the request fails, the URL is invalid, or decoding fails.
    func fetchPlaceDetails(placeId: String) async throws -> PlaceDetails {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&key=\(ApiKeys.googleAPIkey)"
        
        guard let url = URL(string: urlString) else {
            throw ApiError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ApiError.requestFailed
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(PlaceDetailsApiResponse.self, from: data)
            return apiResponse.result
        } catch {
            throw ApiError.decodingError
        }
    }
    
    /// Geocodes a city name to obtain its coordinates.
    /// - Parameter cityName: The name of the city to geocode.
    /// - Returns: The coordinates of the city if found, or `nil` if no results are found.
    /// - Throws: An error if the request fails, the URL is invalid, or decoding fails.
    func geocodeCity(cityName: String) async throws -> CLLocationCoordinate2D? {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&key=\(ApiKeys.googleAPIkey)"
        
        guard let url = URL(string: urlString) else {
            throw ApiError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ApiError.requestFailed
        }
        
        do {
            let geocodeResponse = try JSONDecoder().decode(GeocodeApiResponse.self, from: data)
            return geocodeResponse.results.first?.geometry.location.coordinate
        } catch {
            throw ApiError.decodingError
        }
    }
}
