//
//  MapsSceneViewController.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 19.03.2022.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

// MARK: - Protocol
protocol MapsSceneViewDelegate: NSObjectProtocol {
    func removeAllOverlays()
    func showRoutes(_ routesArray: [UserPersistedRoute])
    func showNoPersistedRoutesMessage()
}

// MARK: - Implementation
extension MapsSceneViewController: MapsSceneViewDelegate {
    func removeAllOverlays() {
        mapView.removeOverlays(mapView.overlays)
    }
    
    func showRoutes(_ routesArray: [UserPersistedRoute]) {
        guard let lastRoute = routesArray.last else { return }
        
        var coordinatesArray: [CLLocationCoordinate2D] = []
        lastRoute.coordinates.forEach { coordinate in
            coordinatesArray.append(coordinate.coordinate)
        }
        
        isTracking = false
        
        let myRoutePolyLine = MKPolyline(coordinates: coordinatesArray, count: coordinatesArray.count)
        mapView.addOverlay(myRoutePolyLine)
        
        if let middle = coordinatesArray.middle {
            lastLocation = CLLocation(latitude: middle.latitude, longitude: middle.longitude)
            mapView.zoomToLocation(lastLocation!, regionRadius: zoomValue)
        }
        
//        if let firstOverlay = mapView.overlays.first {
//            let rect = mapView.overlays.reduce(firstOverlay.boundingMapRect, {$0.union($1.boundingMapRect)})
//            mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
//            zoomValue = mapView.currentRadius()
//        }
    }
    
    func showNoPersistedRoutesMessage() {
        quickAlert(message: "Нет сохраненных маршрутов.") { self.isShowingPreviousRoute = false }
    }
}

// MARK: - Additional extensions
extension MapsSceneViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if isShowingPreviousRoute == false {
            mapView.zoomToLocation(location, regionRadius: zoomValue)
            lastLocation = location
            }
            
            if isTracking {
                presenter.addCoordinate(location.coordinate)
                let myRoutePolyLine = MKPolyline(coordinates: presenter.coordinates, count: presenter.coordinates.count)
                mapView.addOverlay(myRoutePolyLine)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MapsSceneViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
        
        polyLineRenderer.strokeColor = isShowingPreviousRoute ? .systemRed : .tintColor
        polyLineRenderer.lineWidth = 10
        
        return polyLineRenderer
    }
}

// MARK: - View controller
class MapsSceneViewController: UIViewController {
    lazy var presenter = MapsScenePresenter(locationManager: locationManager, realm: realm)
    
    // MARK: - Services
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    
    // MARK: - Properties
    var zoomValue: Double = 300
    var lastLocation: CLLocation?
    
    var isTracking: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                if self.isTracking {
                    self.startStopTrackingButton.transform = CGAffineTransform(rotationAngle: .pi / 4 * 3)
                    self.startStopTrackingButton.tintColor = UIColor.systemRed
                } else {
                    self.startStopTrackingButton.transform = .identity
                    self.startStopTrackingButton.tintColor = UIColor.tintColor
                }
            }
        }
    }
    
    var isShowingPreviousRoute: Bool = false {
        didSet {
            mapView.isScrollEnabled = isShowingPreviousRoute
            mapView.showsUserLocation = !isShowingPreviousRoute
            
            UIView.animate(withDuration: 0.25) {
                if self.isShowingPreviousRoute {
                    self.showPreviousRouteButton.transform = CGAffineTransform(rotationAngle: .pi / 4 * 3)
                    self.showPreviousRouteButton.tintColor = UIColor.systemRed
                } else {
                    self.showPreviousRouteButton.transform = .identity
                    self.showPreviousRouteButton.tintColor = UIColor.tintColor
                }
            }
        }
    }
    
    // MARK: - Methods
    private func setupScene() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        presenter.configureLocationManager()
        mapView.delegate = self
    }
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startStopTrackingButton: CircularButton!
    @IBOutlet weak var showPreviousRouteButton: CircularButton!
    @IBOutlet weak var zoomInButton: CircularButton!
    @IBOutlet weak var zoomOutButton: CircularButton!
    
    // MARK: - Actions
    @IBAction func startStopTrackingButtonTapped(_ sender: Any) {
        isTracking.toggle()
        isShowingPreviousRoute = false
        removeAllOverlays()
        
        if isTracking { presenter.startTracking() } else { presenter.stopTracking() }
    }
    
    @IBAction func showPreviousRouteButtonTapped(_ sender: Any) {
        if isTracking {
            self.yesNoAlert(title: "Прервать слежение?", message: "Для отображения сохраненных маршрутов необходимо прервать текущее слежение.") { _ in
                self.isTracking = false
                self.isShowingPreviousRoute.toggle()
            }
        } else {
            isShowingPreviousRoute.toggle()
        }
        
        if isShowingPreviousRoute { presenter.loadRoutes() } else { removeAllOverlays() }
    }
    
    @IBAction func zoomInButtonTapped(_ sender: Any) {
        guard zoomValue > 200 else { return }
        
        zoomValue -= 200
        
        if let lastLocation = lastLocation {
            mapView.zoomToLocation(lastLocation, regionRadius: zoomValue)
        }
    }
    
    @IBAction func zoomOutButtonTapped(_ sender: Any) {
        guard zoomValue < 100_000 else { return }
        
        zoomValue += 300
        
        if let lastLocation = lastLocation {
            mapView.zoomToLocation(lastLocation, regionRadius: zoomValue)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDelegate = self
        setupScene()
    }
}
