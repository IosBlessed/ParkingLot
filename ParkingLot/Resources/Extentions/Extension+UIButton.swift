//
//  Extension+UIButton.swift
//  ParkingLot
//
//  Created by Никита Данилович on 25.06.2023.
//

import UIKit

extension UIButton {
    func animateButtonWhenTapping() {
        UIView.animate(
            withDuration: UIButtonExtension.animationDuration,
            animations: {
                self.transform = CGAffineTransform(
                    scaleX: UIButtonExtension.transformingOffsetScale,
                    y: UIButtonExtension.transformingOffsetScale
                )
            },
            completion: { _ in
                UIView.animate(
                    withDuration:  UIButtonExtension.animationDuration
                ) {
                    self.transform = CGAffineTransform.identity
                }
        })
    }
    func activateShadowMode() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = UIButtonExtension.layerShadowOpacity
        self.layer.shadowRadius = UIButtonExtension.layerShadowRadius
        self.layer.shadowOffset = .zero
    }
}
