//
//  ForgotPasswordViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 30.06.2023.
//

import UIKit
import Combine

final class ForgotPasswordViewController: UIViewController {
    // MARK: - Properties
    var viewModel: ForgotPasswordViewModelProtocol!
    private var cancellableStates = [AnyCancellable]()
    private var informationRestorePasswordLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.termsLabel
        label.textColor = CustomSystemColors.contrastText
        label.text = Constants.ForgotPasswordScreen.infromationalLabelText
        label.numberOfLines = Constants.ForgotPasswordScreen.numberOfLinesOfInformationalLabel
        return label
    }()
    private var customTextFieldsStackView: TextFieldsStackView = {
        let textFieldsStack = TextFieldsStackViewBuilder.build()
        textFieldsStack.translatesAutoresizingMaskIntoConstraints = false
        return textFieldsStack
    }()
    private lazy var submitButton: UIButton = {
        let button = CustomButton(
            isMainActor: true,
            isShadowActive: true,
            selector: #selector(submitButtonDidTap),
            target: self
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(
            NSAttributedString(
                string: Constants.ForgotPasswordScreen.confirmButtonTitle,
                attributes: [
                    NSAttributedString.Key.font: Fonts.buttonText!
                ]
            ),
            for: .normal
        )
        button.titleLabel?.textColor = .white
        button.isEnabled = false
        button.alpha = Transparency.semi
        return button
    }()
    private lazy var keyboardCenter: KeyboardRelatedView = {
        let keyboardView = KeyboardRelatedView(targetView: self.view)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.initialSetup()
        return keyboardView
    }()
    private let activityIndicatorViewController: ActivityIndicatorViewController = {
        let activityIndicator = ActivityIndicatorViewController()
        activityIndicator.modalPresentationStyle = .overCurrentContext
        return activityIndicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupEmailTextField()
        setupConstraints()
        setupCancellables()
    }
    
    //MARK: - Behaviour
    private func setupNavigationBar() {
        navigationItem.title = Constants.ForgotPasswordScreen.screenTitle
        let backButton = UIBarButtonItem(
            image: UIImage(named: "Vector"),
            style: .plain,
            target: self,
            action: #selector(navigateBack)
        )
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupEmailTextField() {
        customTextFieldsStackView.setupTextFields(
            with: [
                TextFieldDetails(
                    title: Constants.ForgotPasswordScreen.textFieldTitle,
                    placeholder: Constants.ForgotPasswordScreen.textFieldPlaceholder,
                    isSecured: false,
                    restorationIdentifier: .email
                )
        ])
    }
    
    private func setupConstraints() {
        view.addSubview(informationRestorePasswordLabel)
        view.addSubview(customTextFieldsStackView)
        view.addSubview(submitButton)
      
        informationRestorePasswordLabel.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: Anchors.ForgotPasswordScreen.notificationLabelTopAnchorConstant
        ).isActive = true
        informationRestorePasswordLabel.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor,
            constant: Anchors.ForgotPasswordScreen.notificationLabelLeadingTrailingAnchorConstant
        ).isActive = true
        informationRestorePasswordLabel.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor,
            constant: -Anchors.ForgotPasswordScreen.notificationLabelLeadingTrailingAnchorConstant
        ).isActive = true
        informationRestorePasswordLabel.heightAnchor.constraint(
            equalToConstant: Anchors.ForgotPasswordScreen.notificationLabelHeightAnchorConstant
        ).isActive = true
        
        customTextFieldsStackView.topAnchor.constraint(
            equalTo: informationRestorePasswordLabel.bottomAnchor,
            constant: Anchors.ForgotPasswordScreen.customTextFieldsStackViewTopAnchorConstant
        ).isActive = true
        customTextFieldsStackView.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor,
            constant: Anchors.ForgotPasswordScreen.customTextFieldsStackViewLeadingTrailingAnchorConstant
        ).isActive = true
        customTextFieldsStackView.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor,
            constant: -Anchors.ForgotPasswordScreen.customTextFieldsStackViewLeadingTrailingAnchorConstant
        ).isActive = true
        customTextFieldsStackView.heightAnchor.constraint(
            equalToConstant: customTextFieldsStackView.getHeightOfStackView
        ).isActive = true
        
        submitButton.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor,
            constant: Anchors.ForgotPasswordScreen.submitButtonLeadingTrailingAnchorConstant
        ).isActive = true
        submitButton.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor,
            constant: -Anchors.ForgotPasswordScreen.submitButtonLeadingTrailingAnchorConstant
        ).isActive = true
        submitButton.bottomAnchor.constraint(
            equalTo: keyboardCenter.topAnchor,
            constant: Anchors.ForgotPasswordScreen.submitButtonBottomAnchorConstant
        ).isActive = true
        submitButton.heightAnchor.constraint(
            equalToConstant: Anchors.ForgotPasswordScreen.submitButtonHeightAnchorConstant
        ).isActive = true
    }
    
    private func setupCancellables() {
        customTextFieldsStackView
            .$textFieldsEmptyStatePublisher
            .sink { [weak self] isEmptyEmail in
                guard let self else { return }
                self.submitButton.isEnabled = !isEmptyEmail
                self.submitButton.alpha = isEmptyEmail ? Transparency.semi : Transparency.opaque
            }.store(in: &cancellableStates)
        
        viewModel.receivedMessageFromSever.sink { [weak self] receivedMessage in
            guard let self, let receivedMessage else { return }
            self.activityIndicatorViewController.dismiss(animated: false)
            let responseMessage = self.showAlertMessage(
                title: "Notification",
                desriptionMessage: receivedMessage,
                actionButtonTitle: "OK",
                destructiveHandler: { _ in },
                handler: { _ in }
            )
            self.present(responseMessage, animated: true)
        }.store(in: &cancellableStates)
        
        viewModel.emailTextFieldIsValid.sink { [weak self] isValid in
            guard let self else { return }
            if isValid {
                self.present(activityIndicatorViewController, animated: false)
                let emailTextField = self.viewModel.getEmailTextField(textFieldsStackView: customTextFieldsStackView)
                let email = emailTextField.text
                self.viewModel.userRequestRestorePassword(email: email)
            }
        }.store(in: &cancellableStates)
    }
    
    // MARK: - Selectors
    @objc private func navigateBack() {
        self.navigationController?.popViewController(animated:true)
    }
    
    @objc private func submitButtonDidTap() {
        submitButton.animateButtonWhenTapping()
        viewModel.processEmailTextField(textFieldsStackView: self.customTextFieldsStackView)
    }
}
