//
//  ContentView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 01.07.24.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var ratingViewModel = RatingViewModel()

    var body: some View {
        NavigationStack {
            TabView(selection: $viewModel.selectedTab) {
                // Map Tab
                MapView(
                    centerCoordinate: $viewModel.centerCoordinate,
                    places: $viewModel.places,
                    selectedPlaceDetails: $viewModel.selectedPlaceDetails,
                    showingDetails: $viewModel.showingDetails,
                    searchText: $viewModel.searchText,
                    onSearch: {
                        viewModel.searchCity(cityName: viewModel.searchText)
                    },
                    currentLocation: viewModel.currentLocation
                )
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(0)
                
                // Reservation History Tab
                ReservationHistoryView()
                    .tabItem {
                        Image(systemName: "book")
                        Text("Reservations")
                    }
                    .tag(1)
                
                // Ratings Tab
                RatingView(ratingViewModel: ratingViewModel)
                    .tabItem {
                        Image(systemName: "star")
                        Text("Ratings")
                    }
                    .tag(2)
                
                // Profile Tab
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(3)
            }
            .navigationBarItems(trailing: Button(action: {
                viewModel.showingSettings.toggle()
            }) {
                Image(systemName: "gear")
            })
            .sheet(isPresented: $viewModel.showingSettings) {
                SettingsView()
                    .environmentObject(viewModel)
            }
            .onAppear {
                // Fetch bookable places when the view appears
                viewModel.fetchBookablePlaces(at: viewModel.centerCoordinate)
            }
            .navigationDestination(isPresented: $viewModel.showingDetails) {
                // Navigate to place details view if details are available
                if let placeDetails = viewModel.selectedPlaceDetails {
                    PlaceDetailsView(placeDetails: placeDetails)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
