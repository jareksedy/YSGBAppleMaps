//
//  MapsScenePresenter.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 19.03.2022.
//

import UIKit
import CoreLocation
import RealmSwift

// MARK: - Presenter
final class MapsScenePresenter {
    weak var viewDelegate: MapsSceneViewDelegate?
    
    // MARK: - Public properties
    var coordinates: [CLLocationCoordinate2D] = []
    var persistedRoutesCount: Int { realm.objects(UserPersistedRoute.self).count }
    
    // MARK: - Services
    private let locationManager: CLLocationManager
    private let realm: Realm
    
    // MARK: - Initializers
    init(locationManager: CLLocationManager, realm: Realm) {
        self.locationManager = locationManager
        self.realm = realm
    }
    
    // MARK: - Public methods
    func configureLocationManager() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = viewDelegate as? CLLocationManagerDelegate
        locationManager.startUpdatingLocation()
    }
    
    func startTracking() {
        viewDelegate?.showStartTrackingMessage()
        coordinates.removeAll()
    }
    
    func stopTracking() {
        viewDelegate?.showStopTrackingMessage()
        saveRouteToRealm(coordinates)
        viewDelegate?.removeAllOverlays()
    }
    
    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        coordinates.append(coordinate)
    }
    
    func loadRoutes() {
        let routesArray = getPersistedRoutes()
        if routesArray.count > 0 {
            viewDelegate?.showRoute(routesArray, index: persistedRoutesCount - 1)
        } else {
            viewDelegate?.showNoPersistedRoutesMessage()
        }
    }
    
    func getPersistedRoutes() -> [UserPersistedRoute] {
        return Array(realm.objects(UserPersistedRoute.self))
    }
    
    func deleteAllPersistedRoutes() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    // MARK: - Privte methods
    private func saveRouteToRealm(_ coordinates: [CLLocationCoordinate2D]) {
        let userPersistedRoute = UserPersistedRoute()
        
        coordinates.forEach { coordinate in
            let location = Location()
            location.latitude = coordinate.latitude
            location.longitude = coordinate.longitude
            userPersistedRoute.coordinates.append(location)
        }
        
        try! realm.write {
            realm.add(userPersistedRoute)
        }
    }
}
