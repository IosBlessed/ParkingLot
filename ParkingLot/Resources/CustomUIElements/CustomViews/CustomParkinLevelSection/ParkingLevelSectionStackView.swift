//
//  ParkingLevelSectionStackView.swift
//  ParkingLot
//
//  Created by Никита Данилович on 03.07.2023.
//

import Foundation
import UIKit

final class ParkingLevelSectionStackView: UIStackView {
    
    private var stackViewContainer = UIStackView()
    private let label = UILabel()
    
    lazy var section: TextFieldsStackView = {
        let stackView = TextFieldsStackView(frame: .zero)
        return stackView
    }()
    
    private let button = UIButton(type: .system)
    var buttonTappedHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSection()
        setupContainer()
        setupButton()
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupSection()
        setupContainer()
    }
    
    func setupSection(title: String, placeholder: String, isSecured: Bool, identifier: TextFieldsIdentifier) {
        section.setupTextFields(with: [
            TextFieldDetails(title: title,
                             placeholder: placeholder,
                             isSecured: isSecured,
                             restorationIdentifier: identifier)
        ])
        
        (section.stackView.arrangedSubviews as! [CustomTextFieldView]).forEach { CustomTextFieldView in
            CustomTextFieldView.customTextField.keyboardType = .numberPad
        }
    }
    
    private func setupSection() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.spacing = 16.5
        
        self.addArrangedSubview(label)
        self.addArrangedSubview(stackViewContainer)
        
    }
    
    
    func setupLabel(labelText: String) {
        label.text = labelText
        label.font = Fonts.termsLabel
        label.textColor = .black.withAlphaComponent(Transparency.semi)
    }
    
    private func setupContainer() {
        stackViewContainer.addArrangedSubview(section)
        stackViewContainer.addArrangedSubview(button)
        stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        stackViewContainer.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        stackViewContainer.axis = .horizontal
        stackViewContainer.distribution = .fillProportionally
        stackViewContainer.spacing = 3
    }
    
    func setupButton() {
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        buttonTappedHandler?()
    }
}
