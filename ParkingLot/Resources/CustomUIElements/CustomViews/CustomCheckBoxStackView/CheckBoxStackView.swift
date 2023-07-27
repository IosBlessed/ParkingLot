//
//  CheckBoxCustomViewStack.swift
//  ParkingLot
//
//  Created by Никита Данилович on 01.07.2023.
//

import Foundation
import UIKit

final class CheckBoxCustomStackView: UIStackView {
    
    var checkbox = CheckboxButton()
    private var label = UILabel()
    var identifier: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        arrangeSubviews()
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        arrangeSubviews()
        commonInit()
    }

    func arrangeSubviews() {
        addArrangedSubview(checkbox)
        addArrangedSubview(label)
    }
    
    func setLabelText(text: String) {
        self.label.text = text
    }
    
    func changeCheckboxStatus() {
        checkbox.toggleButtonStatus()
        if checkbox.isEnabled {
            self.checkbox.alpha = 1
                    self.label.alpha = 1
        } else {
            self.checkbox.alpha = 0.2
                    self.label.alpha = 0.2
        }
        
    }
    
    private func commonInit() {
        spacing = 8
        
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkbox.widthAnchor.constraint(equalToConstant: 18),
            checkbox.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        label.font = Fonts.termsLabel
        label.textColor = .black.withAlphaComponent(Transparency.semi)
    }
    
}
