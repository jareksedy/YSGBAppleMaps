//
//  MapsSceneViewController.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 19.03.2022.
//

import UIKit
import MapKit
import CoreLocation

// MARK: - Protocol
protocol MapsSceneViewDelegate: NSObjectProtocol {
}

// MARK: - Implementation
extension MapsSceneViewController: MapsSceneViewDelegate {
}

// MARK: - Additional extensions
extension MapsSceneViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            mapView.zoomToLocation(location, regionRadius: zoomValue)
            lastLocation = location
            
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
        
        polyLineRenderer.strokeColor = .tintColor.withAlphaComponent(0.25)
        polyLineRenderer.lineWidth = 10
        
        return polyLineRenderer
    }
}

// MARK: - View controller
class MapsSceneViewController: UIViewController {
    lazy var presenter = MapsScenePresenter(locationManager: locationManager)
    
    // MARK: - Services
    let locationManager = CLLocationManager()
    
    // MARK: - Properties
    var zoomValue: Double = 200
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
    }
    
    @IBAction func showPreviousRouteButtonTapped(_ sender: Any) {
        isShowingPreviousRoute.toggle()
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
        
        zoomValue += zoomValue
        
        if let lastLocation = lastLocation {
            mapView.zoomToLocation(lastLocation, regionRadius: zoomValue)
        }
    }
    
    // MARK: - Selectors
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDelegate = self
        setupScene()
    }
}
