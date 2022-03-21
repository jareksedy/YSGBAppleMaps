//
//  RouteModel.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 21.03.2022.
//

import RealmSwift
import CoreLocation

class UserPersistedRoute: Object {
    let coordinates = List<Location>()
}

class Location: Object {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
