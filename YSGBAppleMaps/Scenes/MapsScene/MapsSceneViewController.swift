//
//  MapsSceneViewController.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 19.03.2022.
//

import UIKit

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
    }

    // MARK: - Outlets
    
    // MARK: - Actions
    
    // MARK: - Selectors
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDelegate = self
        setupUI()
    }
}
