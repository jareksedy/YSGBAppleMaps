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
    var isTracking: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                if self.isTracking {
                    self.startStopTrackingButton.transform = CGAffineTransform(rotationAngle: (.pi / 4) * 3)
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
                    self.showPreviousRouteButton.transform = CGAffineTransform(rotationAngle: (.pi / 4) * 3)
                    self.showPreviousRouteButton.tintColor = UIColor.systemRed
                } else {
                    self.showPreviousRouteButton.transform = .identity
                    self.showPreviousRouteButton.tintColor = UIColor.tintColor
                }
            }
        }
    }
    
    // MARK: - Methods
    private func setupUI() {
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
        setupUI()
    }
}
