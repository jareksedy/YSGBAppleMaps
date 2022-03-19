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
    
    // MARK: - Methods
    private func setupUI() {
        startStopTrackingButton.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        startStopTrackingButton.layer.cornerRadius = 50
        startStopTrackingButton.layer.shadowColor = UIColor.black.cgColor
        startStopTrackingButton.layer.shadowOpacity = 0.25
        startStopTrackingButton.layer.shadowOffset = .zero
        startStopTrackingButton.layer.shadowRadius = 5
    }

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startStopTrackingButton: UIButton!
    
    
    // MARK: - Actions
    
    // MARK: - Selectors
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDelegate = self
        setupUI()
    }
}
