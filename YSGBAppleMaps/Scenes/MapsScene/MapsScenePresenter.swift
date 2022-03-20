//
//  MapsScenePresenter.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 19.03.2022.
//

import UIKit
import CoreLocation

// MARK: - Presenter
final class MapsScenePresenter {
    weak var viewDelegate: MapsSceneViewDelegate?
    
    // MARK: - Public properties
    var coordinates: [CLLocationCoordinate2D] = []
    
    // MARK: - Services
    private let locationManager: CLLocationManager
    
    // MARK: - Initializers
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
    
    // MARK: - Public methods
    func configureLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = viewDelegate as? CLLocationManagerDelegate
        locationManager.startUpdatingLocation()
    }
    
    func startTracking() {
        
    }
    
    func stopTracking() {
        coordinates = []
    }
    
    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        coordinates.insert(coordinate, at: coordinates.count)
    }
}
