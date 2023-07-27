//
//  TextFieldView.swift
//  ParkingLot
//
//  Created by Никита Данилович on 15.06.2023.
//

import Foundation
import UIKit
import Combine

class CustomTextFieldView: UIView, UITextFieldDelegate {
    // MARK: - Properties
    private var cancellableResources = [AnyCancellable]()
    
    private var isSecured: Bool = false {
        didSet {
            self.eyePasswordButton.isHidden = !isSecured
            customTextField.isSecureTextEntry = isSecured
        }
    }
    
    var isCorrect: Bool! {
        didSet {
            customTextField.isCorrect = isCorrect
            customTextField.textColor = isCorrect ? .black : .red
        }
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.textFieldName
        label.textColor = .black.withAlphaComponent(Transparency.semi)
        label.text = "Name"
        label.backgroundColor = CustomSystemColors.primary
        return label
    }()
    
    lazy var customTextField: CustomTextField = {
        let textField = CustomTextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.placeholder = "Test placeholder..."
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.customTextFieldErrorLabel
        label.textColor = .red
        return label
    }()
    
    private lazy var eyePasswordButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .gray
        button.isHidden = true
        button.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
        customTextField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Coder is unknown")
    }
    
    // MARK: - Behaviour
    func fillTextFieldView(with textFieldDetails: TextFieldDetails) {
        self.customTextField.placeholder = textFieldDetails.placeholder
        self.customTextField.restorationIdentifier = textFieldDetails.restorationIdentifier.rawValue
        self.titleLabel.text = textFieldDetails.title
        self.isSecured = textFieldDetails.isSecured
    }
    
    func setupErrorLabelText(with text: String) {
        self.errorLabel.text = text
    }
    
    private func initialSetup() {
        customTextField.initialSetup()
        setupConstraints()
        setupSinchronization()
    }
    
    private func setupSinchronization() {
        customTextField.isCorrectPublisher.sink { isCorrect in
            self.errorLabel.isHidden = isCorrect
            self.customTextField.textColor = isCorrect ? .black : .red
        }.store(in: &cancellableResources)
    }
    
    private func setupConstraints() {
        self.addSubview(customTextField)
        self.addSubview(titleLabel)
        self.addSubview(errorLabel)
        self.addSubview(eyePasswordButton)
        
        customTextField.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: Anchors.CustomTextFields.customTextFieldTopAnchorConstraint
        ).isActive = true
        customTextField.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: Anchors.CustomTextFields.customTextFieldLeadingAnchorConstraint
        ).isActive = true
        customTextField.trailingAnchor.constraint(
            equalTo: self.trailingAnchor,
            constant: Anchors.CustomTextFields.customTextFieldTrailingAnchorConstraint
        ).isActive = true
        customTextField.bottomAnchor.constraint(
            equalTo: self.bottomAnchor,
            constant: Anchors.CustomTextFields.customTextFieldBottomAnchorConstraint
        ).isActive = true
        
        titleLabel.topAnchor.constraint(
            equalTo: customTextField.topAnchor,
            constant: Anchors.CustomTextFields.titleLabelTopAnchorConstraint
        ).isActive = true
        titleLabel.leadingAnchor.constraint(
            equalTo: customTextField.leadingAnchor,
            constant: Anchors.CustomTextFields.titleLabelLeadingAnchorConstrain
        ).isActive = true
        titleLabel.heightAnchor.constraint(
            equalToConstant: Anchors.CustomTextFields.titleLabelHeightAnchorConstrain
        ).isActive = true
        
        errorLabel.topAnchor.constraint(
            equalTo: customTextField.bottomAnchor
        ).isActive = true
        errorLabel.leadingAnchor.constraint(
            equalTo: customTextField.leadingAnchor,
            constant: Anchors.CustomTextFields.errorLabelLeadingAnchorConstraint
        ).isActive = true
        errorLabel.trailingAnchor.constraint(
            equalTo: customTextField.trailingAnchor,
            constant: Anchors.CustomTextFields.errorLabelTrailingAnchorConstraint
        ).isActive = true
        errorLabel.heightAnchor.constraint(
            equalToConstant: Anchors.CustomTextFields.errorLabelHeightAnchorConstraint
        ).isActive = true
        
        eyePasswordButton.centerYAnchor.constraint(
            equalTo: customTextField.centerYAnchor
        ).isActive = true
        eyePasswordButton.trailingAnchor.constraint(
            equalTo: customTextField.trailingAnchor,
            constant: Anchors.CustomTextFields.eyePasswordButtonTrailingAnchorConstraint
        ).isActive = true
        eyePasswordButton.widthAnchor.constraint(
            equalToConstant: Anchors.CustomTextFields.eyePasswordButtonWidthAnchorConstraint
        ).isActive = true
        eyePasswordButton.heightAnchor.constraint(
            equalToConstant: Anchors.CustomTextFields.eyePasswordButtonHeightAnchorConstraint
        ).isActive = true
    }
    // MARK: - Selectors
    @objc private func eyeButtonTapped() {
        let currentState = self.customTextField.isSecureTextEntry
        let switchedImageName = currentState ? "eye.fill" : "eye.slash.fill"
        self.eyePasswordButton.setBackgroundImage(UIImage(systemName: switchedImageName), for: .normal)
        self.customTextField.isSecureTextEntry = !currentState
    }
}
