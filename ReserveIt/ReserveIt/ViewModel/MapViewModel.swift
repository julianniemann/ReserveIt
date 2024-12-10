//
//  ContentViewModel.swift
//  ReserveIt
//
//  Created by Julian Niemann on 23.07.24.
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

/// ViewModel managing map-related data and interactions.
class MapViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Search query for place types (e.g., "restaurant", "hotel").
    @Published var query: String = "all"
    
    /// Radius for searching places around the current location.
    @Published var radius: Double = 1500.0
    
    /// Index of the selected tab in the tab view.
    @Published var selectedTab = 0
    
    /// List of places fetched based on the current search criteria.
    @Published var places: [Place] = []
    
    /// Details of the currently selected place.
    @Published var selectedPlaceDetails: PlaceDetails?
    
    /// Text for searching cities or addresses.
    @Published var searchText: String = ""
    
    /// Current center coordinate of the map.
    @Published var centerCoordinate = CLLocationCoordinate2D(latitude: 52.37052, longitude: 9.73322)
    
    /// User's current location.
    @Published var currentLocation = CLLocationCoordinate2D(latitude: 52.37052, longitude: 9.73322)
    
    /// Flag indicating whether the settings view is shown.
    @Published var showingSettings = false
    
    /// Flag indicating whether place details are shown.
    @Published var showingDetails = false
    
    // MARK: - Private Properties
    
    /// Repository for fetching places data from an API.
    private let placesRepository = PlacesRepository()
    
    /// Service for managing location updates and authorization.
    private let locationService = LocationService()
    
    /// Set of cancellables for Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupLocationService()
    }
    
    // MARK: - Private Methods
    
    /// Configures the location service and sets up subscriptions for location updates and authorization status.
    private func setupLocationService() {
        locationService.requestLocationUpdates()
        
        locationService.$lastKnownLocation
            .sink { [weak self] location in
                if let location = location {
                    self?.centerCoordinate = location.coordinate
                    self?.currentLocation = location.coordinate
                    self?.fetchBookablePlaces(at: location.coordinate)
                }
            }
            .store(in: &cancellables)
        
        locationService.$authorizationStatus
            .sink { [weak self] status in
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    self?.locationService.requestLocationUpdates()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Searches for places in a city and updates the map with the results.
    /// - Parameter cityName: Name of the city to search for.
    func searchCity(cityName: String) {
        Task {
            do {
                if let location = try await placesRepository.geocodeCity(cityName: cityName) {
                    centerCoordinate = location
                    fetchBookablePlaces(at: location)
                }
            } catch {
                print("Error geocoding city: \(error)")
            }
        }
    }
    
    /// Fetches places based on the current query and location, and updates the `places` property.
    /// - Parameter location: Location to search for places around.
    func fetchBookablePlaces(at location: CLLocationCoordinate2D) {
        Task {
            do {
                var allPlaces: [Place] = []
                if query == "all" {
                    let queries = ["restaurant", "hotel", "cinema", "sports complex", "event venue", "theater", "conference center"]
                    for query in queries {
                        let fetchedPlaces = try await placesRepository.searchPlaces(near: location, radius: Int(radius), query: query)
                        allPlaces.append(contentsOf: fetchedPlaces)
                    }
                } else {
                    let fetchedPlaces = try await placesRepository.searchPlaces(near: location, radius: Int(radius), query: query)
                    allPlaces.append(contentsOf: fetchedPlaces)
                }
                places = removeDuplicates(from: allPlaces)
            } catch {
                print("Error fetching places: \(error)")
            }
        }
    }
    
    /// Removes duplicate places from the list based on their unique ID.
    /// - Parameter places: List of places to filter.
    /// - Returns: A list of unique places.
    func removeDuplicates(from places: [Place]) -> [Place] {
        var uniquePlacesById = [String: Place]()
        for place in places {
            uniquePlacesById[place.place_id] = place
        }
        return Array(uniquePlacesById.values)
    }
}
