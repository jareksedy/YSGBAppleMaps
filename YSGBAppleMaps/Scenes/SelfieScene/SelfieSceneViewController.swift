//
//  SelfieSceneViewController.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 17.04.2022.
//

import UIKit

// MARK: - Protocol
protocol SelfieSceneViewDelegate: NSObjectProtocol {
}

// MARK: - Implementation
extension SelfieSceneViewController: SelfieSceneViewDelegate {
}

// MARK: - Additional extensions
// MARK: - View controller
class SelfieSceneViewController: UIViewController {
    lazy var presenter = SelfieScenePresenter()
    
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
