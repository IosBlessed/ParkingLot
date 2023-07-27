//
//  CustomTextField.swift
//  ParkingLot
//
//  Created by Никита Данилович on 15.06.2023.
//

import Combine
import UIKit

class CustomTextField: UITextField {
    // MARK: - Published
    var isCorrectPublisher: Published<Bool>.Publisher { $_isCorrect }
    @Published private var _isCorrect: Bool = true
    
    // MARK: - Properties
    private lazy var textPadding = UIEdgeInsets(
        top: Padding.customTextFieldTexTop,
        left: Padding.customTextFieldTexLeft,
        bottom: Padding.customTextFieldTexBottom,
        right: Padding.customTextFieldTexRight)
    
    // MARK: - Lifecycle
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
        
    // MARK: - Behaviour
    func initialSetup() {
        self.font = Fonts.customTextField
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.layer.cornerRadius = CornerRadious.customTextFiel
        self.layer.borderColor = UIColor.black.withAlphaComponent(Transparency.pointTwo).cgColor
        self.layer.borderWidth = BorderWidth.customTextField
        self.keyboardType = .default
    }
}

extension CustomTextField {
    // MARK: - observer
    var isCorrect: Bool {
        get {
            return _isCorrect
        }
        set {
            _isCorrect = newValue
        }
    }
}
