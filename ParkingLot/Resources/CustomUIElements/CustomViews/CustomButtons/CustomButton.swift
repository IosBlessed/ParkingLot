//
//  CustomButton.swift
//  ParkingLot
//
//  Created by Никита Данилович on 25.06.2023.
//

import UIKit

class CustomButton: UIButton {
    // MARK: - Porperties
    private var isMainActor: Bool = false
    private var isShadowActive: Bool = false
    private var selector: Selector?
    private var target: Any?
    // MARK: - Lifecycle
    init(isMainActor: Bool = false, isShadowActive: Bool = false, selector: Selector? = nil, target: Any? = nil ) {
        super.init(frame: .zero)
        self.isMainActor = isMainActor
        self.isShadowActive = isShadowActive
        self.selector = selector
        self.target = target
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Unknown coder been sended...")
    }
    // MARK: - Behaviour 
    private func initialSetup() {
        self.backgroundColor = isMainActor ? UIColor(named: "DefaultRed") : UIColor.clear
        self.tintColor = isMainActor ? UIColor.white : UIColor.black
        self.clipsToBounds = false
        self.layer.borderColor = isMainActor ? UIColor.clear.cgColor : UIColor.gray.cgColor
        self.layer.borderWidth = UIButtonExtension.borderWidth
        self.layer.cornerRadius = UIButtonExtension.cornerRadius
        if isShadowActive {
            self.activateShadowMode()
        }
        guard let selector else { return }
        self.addTarget(target, action: selector, for: .touchUpInside)
    }
}

extension CustomButton {
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 0.9
        rotation.isCumulative = false
        rotation.repeatCount = 1
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
