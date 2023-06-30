//
//  LocationViewModel.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 24/01/2023.
//

import SwiftUI
import CoreLocation

///
/// https://www.andyibanez.com/posts/using-corelocation-with-swiftui/
///
/// https://useyourloaf.com/blog/xcode-13-missing-info.plist/
///

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    
    private let locationManager: CLLocationManager
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        fetchCountryAndCity(for: locations.first)
    }
    
    func fetchCountryAndCity(for location: CLLocation?)  {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.currentPlacemark = placemarks?.first
        }

    }
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
}

///
/// GetCurrentLocation returnerer latitude og longitude:
///
func GetCurrentLocation(_ locationViewModel: LocationViewModel) async -> (latitude: Double, longitude: Double) {
    
    var latitude: Double = 0.00
    var longitude: Double = 0.00

    latitude = locationViewModel.lastSeenLocation?.coordinate.latitude ?? 0.00
    longitude = locationViewModel.lastSeenLocation?.coordinate.longitude ?? 0.00
    
    if latitude == 0.00, longitude == 0.00 {
        var value: (Double, Double)
        value = await FindLocalPosition()
        latitude = value.0
        longitude = value.1
    }
    
    return (latitude, longitude)
}
