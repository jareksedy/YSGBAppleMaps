//
//  Alerts.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 20.03.2022.
//

import UIKit

extension UIViewController {
    func yesNoAlert(title: String = "", message: String, completionHandler: ((UIAlertAction) -> Void)? = nil) {
        guard self.presentedViewController as? UIAlertController == nil else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: completionHandler))
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}
