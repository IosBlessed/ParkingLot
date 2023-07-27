//
//  Extension+UIViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 27.06.2023.
//

import UIKit

extension UIViewController {
    func showAlertMessage(
        title: String,
        desriptionMessage: String,
        actionButtonTitle: String,
        destructiveButtonTitle: String? = nil,
        destructiveHandler: @escaping (UIAlertAction) -> Void,
        handler: @escaping (UIAlertAction) -> Void
    ) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: desriptionMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionButtonTitle, style: .default, handler: handler)
        alertController.addAction(action)
        if let destructiveButtonTitle {
            let destructiveAction = UIAlertAction(
                title: destructiveButtonTitle,
                style: .destructive,
                handler: destructiveHandler
            )
            alertController.addAction(destructiveAction)
        }
        return alertController
    }
}
