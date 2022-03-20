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
            presenter.addCoordinateToArray(location.coordinate)
            mapView.zoomToLocation(location, regionRadius: 200)
            
            let myRoutePolyLine = MKPolyline(coordinates: presenter.coordinates, count: presenter.coordinates.count)
            mapView.addOverlay(myRoutePolyLine)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MapsSceneViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
        
        polyLineRenderer.strokeColor = .tintColor.withAlphaComponent(0.15)
        polyLineRenderer.lineWidth = 5
        return polyLineRenderer
    }
}

// MARK: - View controller
class MapsSceneViewController: UIViewController {
    lazy var presenter = MapsScenePresenter(locationManager: locationManager)
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    
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
        
        mapView.isZoomEnabled = false
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startStopTrackingButton: UIButton!
    @IBOutlet weak var showPreviousRouteButton: UIButton!
    
    // MARK: - Actions
    @IBAction func startStopTrackingButtonTapped(_ sender: Any) {
        isTracking.toggle()
    }
    
    @IBAction func showPreviousRouteButtonTapped(_ sender: Any) {
        isShowingPreviousRoute.toggle()
    }
    
    // MARK: - Selectors
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDelegate = self
        setupScene()
    }
}
