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
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = viewDelegate as? CLLocationManagerDelegate
        locationManager.startUpdatingLocation()
    }
    
    func startTracking() {
    }
    
    func stopTracking() {
        saveRouteToRealm(coordinates)
        coordinates = []
        viewDelegate?.removeAllOverlays()
    }
    
    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        coordinates.append(coordinate)
    }
    
    func loadRoutes() {
        let routesArray = getPersistedRoutes()
        if routesArray.count > 0 {
            viewDelegate?.showRoutes(routesArray: routesArray)
        } else {
            viewDelegate?.showNoPersistedRoutesMessage()
        }
    }
    
//    func getPersistedRoutesCount() -> Int {
//        return realm.objects(UserPersistedRoute.self).count
//    }
    
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
    
    private func getPersistedRoutes() -> [[CLLocationCoordinate2D]] {
        var routesArray: [[CLLocationCoordinate2D]] = []
        var routesSubArray: [CLLocationCoordinate2D] = []
        
        let routes = Array(realm.objects(UserPersistedRoute.self)) // [UserPersistedRoute]
        
        routes.forEach { route in
            let coordinatesArray = Array(route.coordinates)
            
            coordinatesArray.forEach { coordinate in
                routesSubArray.append(coordinate.coordinate)
            }
            routesArray.append(routesSubArray)
        }
        
        return routesArray
    }
}
