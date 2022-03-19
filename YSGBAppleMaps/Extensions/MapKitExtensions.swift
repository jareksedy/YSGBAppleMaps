//
//  MapKitExtensions.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 19.03.2022.
//

import MapKit

extension MKMapView {
    func zoomToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
