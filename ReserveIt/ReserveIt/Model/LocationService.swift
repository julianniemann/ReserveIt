//
//  LocationService.swift
//  ReserveIt
//
//  Created by Julian Niemann on 23.07.24.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published private(set) var lastKnownLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let clLocationManager = CLLocationManager()

    override init() {
        super.init()
        clLocationManager.delegate = self
        clLocationManager.requestWhenInUseAuthorization()
        clLocationManager.startUpdatingLocation()
    }

    func requestLocationUpdates() {
        clLocationManager.requestWhenInUseAuthorization()
        clLocationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        clLocationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        self.lastKnownLocation = latestLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
}
