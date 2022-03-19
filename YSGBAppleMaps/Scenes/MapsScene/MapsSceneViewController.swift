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

// MARK: - View controller
class MapsSceneViewController: UIViewController {
    lazy var presenter = MapsScenePresenter()
    
    // MARK: - Properties
    var isTracking: Bool = false
    
    // MARK: - Methods
    private func setupUI() {
        startStopTrackingButton.layer.cornerRadius = startStopTrackingButton.frame.width / 2
        showPreviousRouteButton.layer.cornerRadius = showPreviousRouteButton.frame.width / 2
    }

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startStopTrackingButton: UIButton!
    @IBOutlet weak var showPreviousRouteButton: UIButton!
    
    // MARK: - Actions
    @IBAction func startStopTrackingButtonTapped(_ sender: Any) {
        isTracking.toggle()
        
        UIView.animate(withDuration: 0.25) {
            if self.isTracking {
                self.startStopTrackingButton.transform = CGAffineTransform(rotationAngle: (CGFloat.pi / 4) * 3)
                self.startStopTrackingButton.tintColor = UIColor.systemRed
            } else {
                self.startStopTrackingButton.transform = .identity
                self.startStopTrackingButton.tintColor = UIColor.tintColor
            }
        }
    }
    
    @IBAction func showPreviousRouteButtonTapped(_ sender: Any) {
    }
    
    // MARK: - Selectors
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDelegate = self
        setupUI()
    }
}
