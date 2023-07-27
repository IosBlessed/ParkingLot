//
//  CustomCheckBox.swift
//  ParkingLot
//
//  Created by Никита Данилович on 01.07.2023.
//

import Foundation
import UIKit

class CheckboxButton: UIButton {
    
    private var checkmarkImageView = UIImageView()
    var handler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        addSubview(checkmarkImageView)
        setupCheckmarkImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
        setupCheckmarkImageView()
    }
    
    private func setupButton() {
        layer.cornerRadius = 3
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.withAlphaComponent(Transparency.semi).cgColor
        backgroundColor = UIColor.white
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func setupCheckmarkImageView() {
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .white
        checkmarkImageView.isHidden = true
        addSubview(checkmarkImageView)
        
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkmarkImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            checkmarkImageView.topAnchor.constraint(equalTo: topAnchor),
            checkmarkImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func toggleButtonStatus() {
        self.isEnabled.toggle()
    }
    
    @objc func buttonTapped() {
        isSelected = !isSelected
        layer.borderColor = isSelected ? UIColor.red.cgColor : UIColor.black.withAlphaComponent(Transparency.semi).cgColor
        backgroundColor = isSelected ? UIColor.red : UIColor.white
        checkmarkImageView.isHidden = !isSelected
        guard let handler = handler else { return }
            handler()
    }
}
