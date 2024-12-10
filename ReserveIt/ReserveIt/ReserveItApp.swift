//
//  ReserveItApp.swift
//  ReserveIt
//
//  Created by Julian Niemann on 01.07.24.
//

import SwiftUI
import Firebase
import GoogleMaps

@main
struct ReserveItApp: App {
    
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    init() {
        // Initialize Firebase and configure Google Maps
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        GMSServices.provideAPIKey(ApiKeys.googleAPIkey)
        print("Initializing Google Maps")
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isUserLoggedIn {
                // Show ContentView if the user is logged in
                ContentView()
                    .environmentObject(authViewModel)
            } else {
                // Show AuthenticationView if the user is not logged in
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
