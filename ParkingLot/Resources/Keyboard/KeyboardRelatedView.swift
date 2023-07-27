//
//  Keyboard.swift
//  ParkingLot
//
//  Created by Никита Данилович on 20.06.2023.
//

import Foundation
import UIKit

class KeyboardRelatedView: UIView {
    private unowned var targetView: UIView!
    private var keyboardHeight = 0.0
    private var keyboardHeightAnchor: NSLayoutConstraint!
    private var hiddenViews: [UIView]?

    init(targetView: UIView, shouldHideViews: [UIView]? = nil) {
        super.init(frame: .zero)
        self.targetView = targetView
        self.hiddenViews = shouldHideViews
    }
    
    required init?(coder: NSCoder) {
        fatalError("coder not been implemented...")
    }
    
    func registerKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func initialSetup() {
        registerKeyboardObserver()
        initializeHideKeyboardGestureRecognizer()
        setupConstraints()
    }
    
    private func setupConstraints() {
        targetView.addSubview(self)
        self.bottomAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        keyboardHeightAnchor = heightAnchor.constraint(equalToConstant: keyboardHeight)
        keyboardHeightAnchor.isActive = true
    }

    private func initializeHideKeyboardGestureRecognizer() {
        let hideKeyboardGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        targetView.addGestureRecognizer(hideKeyboardGesture)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        self.keyboardHeight = keyboardRectangle.height - targetView.safeAreaInsets.bottom
        self.keyboardHeightAnchor.constant = self.keyboardHeight
        hiddenViews?.forEach { hiddenView in
            hiddenView.layer.opacity = 0.0
        }
        self.targetView.layoutIfNeeded()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.2) {
            self.keyboardHeightAnchor.constant = 0.0
            self.hiddenViews?.forEach { hiddenView in
                hiddenView.layer.opacity = 1.0
            }
            self.targetView.layoutIfNeeded()
        }
    }
    
    @objc private func hideKeyboard() {
        targetView.endEditing(true)
    }
    
    deinit {
        removeObserver()
    }
}
