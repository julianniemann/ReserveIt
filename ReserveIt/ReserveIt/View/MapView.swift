//
//  MapView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 10.07.24.
//

import SwiftUI
import GoogleMaps

/// View displaying the map and related UI components.
struct MapView: View {
    
    // MARK: - Properties
    
    /// Binding to the center coordinate of the map.
    @Binding var centerCoordinate: CLLocationCoordinate2D
    
    /// Binding to the list of places to be shown on the map.
    @Binding var places: [Place]
    
    /// Binding to the details of the selected place.
    @Binding var selectedPlaceDetails: PlaceDetails?
    
    /// Binding to the visibility of the place details view.
    @Binding var showingDetails: Bool
    
    /// Binding to the search text input.
    @Binding var searchText: String
    
    /// Closure to handle search action.
    var onSearch: () -> Void
    
    /// Current location coordinate for centering the map.
    var currentLocation: CLLocationCoordinate2D
    
    /// State to control the visibility of the search bar.
    @State private var showSearchBar = true
    
    var body: some View {
        ZStack(alignment: .top) {
            // Map container view.
            MapContainerView(
                centerCoordinate: $centerCoordinate,
                places: $places,
                selectedPlaceDetails: $selectedPlaceDetails,
                showingDetails: $showingDetails,
                searchText: $searchText,
                onSearch: onSearch
            )
            .edgesIgnoringSafeArea(.top)
            
            // Search bar.
            if showSearchBar {
                HStack {
                    TextField("Search for a city or address", text: $searchText, onCommit: {
                        onSearch()
                    })
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .shadow(radius: 4)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .padding(.top, 1)
            }
            
            // Button to center map on current location.
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        centerCoordinate = currentLocation
                        onSearch()
                    }) {
                        Image(systemName: "location.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(.trailing)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

/// UIViewRepresentable wrapper for Google Maps view.
struct MapContainerView: UIViewRepresentable {
    
    // MARK: - Properties
    
    /// Zoom level for the map.
    private let zoomLevel = 15.0
    
    /// Binding to the center coordinate of the map.
    @Binding var centerCoordinate: CLLocationCoordinate2D
    
    /// Binding to the list of places to be shown on the map.
    @Binding var places: [Place]
    
    /// Binding to the details of the selected place.
    @Binding var selectedPlaceDetails: PlaceDetails?
    
    /// Binding to the visibility of the place details view.
    @Binding var showingDetails: Bool
    
    /// Binding to the search text input.
    @Binding var searchText: String
    
    /// Closure to handle search action.
    var onSearch: () -> Void
    
    // MARK: - UIViewRepresentable Methods
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: Float(zoomLevel))
        let mapView = GMSMapView()
        mapView.camera = camera
        mapView.delegate = context.coordinator
        mapView.setMinZoom(10, maxZoom: 20)
        return mapView
    }
    
    @MainActor
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        DispatchQueue.main.async {
            let camera = GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: Float(zoomLevel))
            uiView.animate(to: camera)
            uiView.clear()
            
            // Add markers for each place.
            for place in places {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
                marker.title = place.name
                marker.snippet = place.vicinity
                marker.icon = getMarkerIcon(for: place)
                marker.map = uiView
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Helper Methods
    
    /// Returns a marker icon based on the place type.
    /// - Parameter place: The place for which the marker icon is being created.
    /// - Returns: An optional UIImage for the marker icon.
    func getMarkerIcon(for place: Place) -> UIImage? {
        let symbolName: String
        
        if let types = place.types {
            if types.contains("cinema") {
                symbolName = "film.fill"
            } else if types.contains("restaurant") {
                symbolName = "fork.knife"
            } else if types.contains("hotel") {
                symbolName = "bed.double.fill"
            } else if types.contains("sports complex") {
                symbolName = "sportscourt.fill"
            } else if types.contains("event venue") {
                symbolName = "music.note.list"
            } else if types.contains("theater") {
                symbolName = "theatermasks.fill"
            } else if types.contains("conference center") {
                symbolName = "person.2.fill"
            } else {
                symbolName = "mappin.and.ellipse"
            }
        } else {
            symbolName = "mappin.and.ellipse"
        }
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        return UIImage(systemName: symbolName, withConfiguration: configuration)
    }
    
    // MARK: - Coordinator
    
    /// Coordinator class to handle map view delegate methods.
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: MapContainerView
        private var lastTappedMarker: GMSMarker?
        
        init(_ parent: MapContainerView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if lastTappedMarker == marker {
                guard let placeId = (parent.places.first { $0.name == marker.title })?.place_id else { return false }
                
                Task {
                    do {
                        let placeDetails = try await PlacesRepository().fetchPlaceDetails(placeId: placeId)
                        parent.selectedPlaceDetails = placeDetails
                        parent.showingDetails = true
                    } catch {
                        print("Error fetching place details: \(error)")
                    }
                }
                lastTappedMarker = nil
            } else {
                lastTappedMarker = marker
            }
            return false
        }
        
        func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
            guard let placeId = (parent.places.first { $0.name == marker.title })?.place_id else { return }
            
            Task {
                do {
                    let placeDetails = try await PlacesRepository().fetchPlaceDetails(placeId: placeId)
                    parent.selectedPlaceDetails = placeDetails
                    parent.showingDetails = true
                } catch {
                    print("Error fetching place details: \(error)")
                }
            }
        }
    }
}
