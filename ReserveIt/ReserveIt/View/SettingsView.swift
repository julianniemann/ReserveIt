//
//  SettingsView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 23.07.24.
//

import SwiftUI

/// View for adjusting search settings.
struct SettingsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var mapViewModel: MapViewModel
    
    private let queries = [
        "all",
        "restaurant",
        "hotel",
        "cinema",
        "sports complex",
        "event venue",
        "theater",
        "conference center"
    ]
    
    var body: some View {
        Form {
            // Search Category Picker
            Section(header: Text("Search Category").font(.headline)) {
                Picker("Select Search Category", selection: $mapViewModel.query) {
                    ForEach(queries, id: \.self) { query in
                        Text(query.capitalized).tag(query)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Search Radius Slider
            Section(header: Text("Search Radius").font(.headline)) {
                HStack {
                    Text("Radius: \(Int(mapViewModel.radius)) meters")
                    Slider(value: $mapViewModel.radius, in: 1000...5000, step: 100)
                }
            }
            
            // Apply Settings Button
            Button(action: applySettings) {
                Text("Apply Settings")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle("Settings")
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Private Methods
    
    /// Applies the settings and updates the map view.
    private func applySettings() {
        mapViewModel.fetchBookablePlaces(at: mapViewModel.centerCoordinate)
        mapViewModel.showingSettings = false
    }
}

// MARK: - Previews

#Preview {
    SettingsView()
        .environmentObject(MapViewModel())
}
