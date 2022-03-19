//
//  RotatingButton.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 19.03.2022.
//

import UIKit

class CircularButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        
       // addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
       // addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    @objc private func animateDown(sender: UIButton) {
        alpha = 0.9
    }
    
    @objc private func animateUp(sender: UIButton) {
        alpha = 1
    }
}
