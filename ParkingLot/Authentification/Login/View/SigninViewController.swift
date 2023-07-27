//
//  SigninViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович  on 14.06.2023.
//

import UIKit
import Combine

struct UserKey {
    static var jwt: String = ""
    static var name: String = ""
    static var role: String = ""
}

class SignInViewController: UIViewController, SignInViewControllerProtocol {
    // MARK: - Properties
    unowned var coordinator: AuthentificationCoordinatorProtocol!
    var viewModel: SignInViewModelProtocol!
    private var cancellableStates = [AnyCancellable]()
    private var customTextFieldsStackView: TextFieldsStackView = {
        let textFieldsStackView = TextFieldsStackViewBuilder.build()
        textFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        return textFieldsStackView
    }()
    private var forgotPasswordLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSAttributedString(
            string: "Forgot password",
            attributes: [
                NSAttributedString.Key.font: Fonts.termsLabel!
            ]
        )
        label.isUserInteractionEnabled = true
        return label
    }()
    private var termsLabel: TermsAndConditionsLabel = {
        let label = TermsAndConditionsLabel(
            labelText: "By proceeding you agree\nto our Terms and Conditions",
            textForLink: "Terms and Conditions",
            urlPath: "https://www.google.com/"
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var confirmButton: CustomButton = {
        let button = CustomButton(
            isMainActor: true,
            isShadowActive: true,
            selector: #selector(confirmButtonTapped),
            target: self
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(
            NSAttributedString(
                string: "Confirm",
                attributes: [
                    NSAttributedString.Key.font: Fonts.buttonText!
                ]
            ),
            for: .normal
        )
        button.titleLabel?.textColor = .white
        button.isEnabled = false
        button.alpha = Transparency.pointThree
        return button
    }()
    private lazy var keyboardView: KeyboardRelatedView = {
        let keyboardView = KeyboardRelatedView(targetView: self.view, shouldHideViews: [self.termsLabel])
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.initialSetup()
        return keyboardView
    }()
    private let activityIndicatorViewController = ActivityIndicatorViewController()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomSystemColors.primary
        setupNavigationBar()
        setupCustomTextFieldsStackView()
        setupForgotPassword()
        setupConstraints()
        setupCancellables()
    }
    // MARK: - Behaviour
    private func setupForgotPassword() {
        let forgotPasswordTap = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordDidTap))
        forgotPasswordLabel.addGestureRecognizer(forgotPasswordTap)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Sign In"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: Fonts.screenTitleLabel!
        ]
        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: "Vector"),
            style: .plain,
            target: self,
            action: #selector(navigationBarBackButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButtonItem
    }

    private func setupCustomTextFieldsStackView() {
        customTextFieldsStackView.setupTextFields(
            with: [
                TextFieldDetails(
                    title: "Email",
                    placeholder: "eg. example@email.com",
                    isSecured: false,
                    restorationIdentifier: .email
                ),
                TextFieldDetails(
                    title: "Password",
                    placeholder: "Password",
                    isSecured: true,
                    restorationIdentifier: .password
                )
            ]
        )
    }
    
    private func setupConstraints() {
        view.addSubview(customTextFieldsStackView)
        view.addSubview(forgotPasswordLabel)
        view.addSubview(termsLabel)
        view.addSubview(confirmButton)
        let textFieldsHeight = customTextFieldsStackView.getHeightOfStackView
        
        customTextFieldsStackView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: Anchors.SignInScreen.textFieldsViewTopAnchorConstant
        ).isActive = true
        customTextFieldsStackView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: Anchors.SignInScreen.textFieldsViewLeadingTrailingAnchorConstant
        ).isActive = true
        customTextFieldsStackView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: -Anchors.SignInScreen.textFieldsViewLeadingTrailingAnchorConstant
        ).isActive = true
        customTextFieldsStackView.heightAnchor.constraint(equalToConstant: textFieldsHeight).isActive = true
        
        forgotPasswordLabel.topAnchor.constraint(
            equalTo: customTextFieldsStackView.bottomAnchor,
            constant: Anchors.SignInScreen.forgotPasswordLabelTopAnchorConstant
        ).isActive = true
        forgotPasswordLabel.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        
        confirmButton.bottomAnchor.constraint(
            equalTo: keyboardView.topAnchor,
            constant: Anchors.SignInScreen.conifrmButtonBottomConstant
        ).isActive = true
        confirmButton.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor,
            constant: Anchors.SignInScreen.confirmButtonLeadingTrailingConstant
        ).isActive = true
        confirmButton.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor,
            constant: -Anchors.SignInScreen.confirmButtonLeadingTrailingConstant
        ).isActive = true
        confirmButton.heightAnchor.constraint(
            equalToConstant: Anchors.SignInScreen.confirmButtonHeightConstant
        ).isActive = true
        
        termsLabel.bottomAnchor.constraint(
            equalTo: confirmButton.topAnchor,
            constant: Anchors.SignInScreen.termsLabelBottomConstant
        ).isActive = true
        termsLabel.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
    }
    
    private func setupCancellables() {
        customTextFieldsStackView.$textFieldsEmptyStatePublisher.sink { areEmptyTextFields in
            self.confirmButton.isEnabled = !areEmptyTextFields
            self.confirmButton.alpha = areEmptyTextFields ? Transparency.pointThree : Transparency.opaque
        }.store(in: &cancellableStates)
        viewModel.textFieldsValidationPublisher.sink { [weak self] textFieldsAreValid in
            guard let self else { return }
            if !textFieldsAreValid {
                self.activityIndicatorViewController.modalPresentationStyle = .overCurrentContext
                self.present(self.activityIndicatorViewController, animated: false)
                self.viewModel.authenticateUser()
            }
        }.store(in: &cancellableStates)
        viewModel.userAuthenticated.sink { [weak self] isAuthenticated in
            guard let isAuthenticated, let self else { return }
            self.activityIndicatorViewController.dismiss(animated: false)
            if isAuthenticated {
                guard let user = viewModel.user else { return }
                KeychainService.shared.saveUser(
                    role: user.role,
                    token: user.jwt,
                    handler: { _ in }
                )
                GlobalUser.role = user.role
                GlobalUser.jwt = user.jwt
                self.coordinator.authenticationDidFinish()
            } else {
                self.userDoesNotExistsInTheSystem()
            }
        }.store(in: &cancellableStates)
    }
    
    // MARK: - Selectors
    @objc private func navigationBarBackButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func userDoesNotExistsInTheSystem() {
        let alertController = self.showAlertMessage(
            title: "Oops...",
            desriptionMessage: "Wrong credentials were introduced!",
            actionButtonTitle: "OK",
            destructiveHandler: { _ in },
            handler: { _ in }
        )
        present(alertController, animated: true)
    }
    @objc private func confirmButtonTapped() {
        confirmButton.animateButtonWhenTapping()
        viewModel.shouldProcessTextFields(
            customTextFieldsStackView: self.customTextFieldsStackView
        )
    }
    
    @objc private func forgotPasswordDidTap() {
        coordinator.moveToForgotPasswordScreen()
    }
}
