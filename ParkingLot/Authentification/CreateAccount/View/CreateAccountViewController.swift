//
//  CreateAccountViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович  on 14.06.2023.
//

import UIKit
import Combine

class CreateAccountViewController: UIViewController, CreateAccountViewControllerProtocol {
    
    var viewModel: CreateAccountViewModelProtocol!
    unowned var coordinator: AuthentificationCoordinatorProtocol!
    private var cancellableStates = [AnyCancellable]()
    private lazy var textFieldsView: TextFieldsStackView = {
        let stackView = TextFieldsStackView(frame: .zero)
        return stackView
    }()
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: self.view.bounds)
        view.addSubview(indicator)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.style = .large
        return indicator
    }()
    private lazy var keyboardView: KeyboardRelatedView = {
        let keyboard = KeyboardRelatedView(targetView: self.view)
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        return keyboard
    }()
    
    private var termsLabel = TermsAndConditionsLabel(
        labelText: "By proceeding you agree\nto our Terms and Conditions",
        textForLink: "Terms and Conditions",
        urlPath: "https://www.google.com/"
    )
    private var termsBottomLabelConstraint: NSLayoutConstraint!
    private var createAccountBottomButtonConstraint: NSLayoutConstraint!
    private lazy var createAccountButton: CustomButton = {
        let customButton = CustomButton(
            isMainActor: true,
            isShadowActive: true,
            selector: #selector(buttonWasTapped),
            target: self
        )
        return customButton
    }()
    private let activityIndicatorViewController = ActivityIndicatorViewController()
}

//MARK: - SETUP
extension CreateAccountViewController {
    private func setupNavBar() {
        navigationItem.title = "Create An Account"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: Fonts.screenTitleLabel!
        ]
        let backButton = UIBarButtonItem(image: UIImage(named: "Vector"), style: .plain, target: self, action: #selector(navigateBack))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func navigateBack() {
        self.navigationController?.popViewController(animated:true)
    }
    
    private func setupTermsLabel() {
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(termsLabel)
        termsBottomLabelConstraint = termsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor , constant: Anchors.CreateAccountScreen.termsLabelBottomAnchorConstraint)
        NSLayoutConstraint.activate([
            termsBottomLabelConstraint,
            termsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            termsLabel.widthAnchor.constraint(equalToConstant: Anchors.CreateAccountScreen.termsLabelWidthAnchorConstraint)
        ])
    }
    
    private func setupStackView() {
        textFieldsView.setupTextFields(
            with: [
                TextFieldDetails(
                    title: "Name",
                    placeholder: "eg. John",
                    isSecured: false,
                    restorationIdentifier: TextFieldsIdentifier.name
                ),
                TextFieldDetails(
                    title: "Email",
                    placeholder: "eg. example@email.com",
                    isSecured: false,
                    restorationIdentifier: TextFieldsIdentifier.email
                ),
                TextFieldDetails(
                    title: "Password",
                    placeholder: "Password",
                    isSecured: true,
                    restorationIdentifier: TextFieldsIdentifier.password
                ),
                TextFieldDetails(
                    title: "Phone",
                    placeholder: "079123123",
                    isSecured: false,
                    restorationIdentifier: TextFieldsIdentifier.phoneNumber
                )
            ]
        )
        
        textFieldsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textFieldsView)
        
        let height = textFieldsView.getHeightOfStackView
        
        NSLayoutConstraint.activate([
            textFieldsView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Anchors.CreateAccountScreen.textFieldsViewLeadingTrailingAnchorConstant
            ),
            textFieldsView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Anchors.CreateAccountScreen.textFieldsViewLeadingTrailingAnchorConstant
            ),
            textFieldsView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Anchors.CreateAccountScreen.textFieldsViewTopAnchorConstant
            ),
            textFieldsView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            textFieldsView.heightAnchor.constraint(
                equalToConstant: height
            )
        ])
    }
    
    private func setupCreateAccountButton() {
        createAccountButton.setTitle("Confirm", for: .normal)
        createAccountButton.titleLabel?.font = Fonts.buttonText
        createAccountButton.backgroundColor = UIColor(named: "DefaultRed")
        createAccountButton.addTarget(self, action: #selector(buttonWasTapped), for: .touchUpInside)
        
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createAccountButton)
        
        createAccountBottomButtonConstraint = createAccountButton.bottomAnchor.constraint(
            equalTo: keyboardView.topAnchor,
            constant: Anchors.CreateAccountScreen.createAccountButtonBottomAnchorConstraint
        )
        
        NSLayoutConstraint.activate([
            createAccountButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Anchors.CreateAccountScreen.createAccountButtonLeadingTrailingAnchorConstraint
            ),
            createAccountButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Anchors.CreateAccountScreen.createAccountButtonLeadingTrailingAnchorConstraint
            ),
            createAccountBottomButtonConstraint,
            createAccountButton.heightAnchor.constraint(
                equalToConstant: Anchors.CreateAccountScreen.createAccountButtonHeightAnchorConstraint
            )
        ])
    }
    
    @objc private func buttonWasTapped() {
        guard let fields = textFieldsView.stackView.arrangedSubviews as? [CustomTextFieldView] else { return }
        viewModel.confirmButtonWasTapped(customTextFieldView: fields)
    }
    private func userAlreadyExistsAlert() {
        let alertViewController = self.showAlertMessage(
            title: "Registration error",
            desriptionMessage: "Account with the same phone number or email already exists!",
            actionButtonTitle: "OK",
            destructiveHandler: { _ in },
            handler: { _ in }
        )
        present(alertViewController, animated: true)
    }
    
    private func setupCancellables() {
        viewModel.shouldEnableButton.sink { [unowned self] areTextFieldsEmpty in
            self.createAccountButton.isUserInteractionEnabled = !areTextFieldsEmpty
            self.createAccountButton.alpha = !self.createAccountButton.isUserInteractionEnabled ? Transparency.pointThree : Transparency.opaque
        }.store(in: &cancellableStates)
        
        viewModel.createUserQueryIsProcessing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] createUserIsProcessing in
                guard let self, let createUserIsProcessing else { return }
                if createUserIsProcessing {
                    self.activityIndicatorViewController.modalPresentationStyle = .overCurrentContext
                    self.present(self.activityIndicatorViewController, animated: false)
                } else {
                    self.activityIndicatorViewController.dismiss(animated: false)
                }
                
        }.store(in: &cancellableStates)
        
        viewModel.userBeenCreated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] successfulResponse in
            guard let successfulResponse else { return }
                if !successfulResponse {
                    self?.userAlreadyExistsAlert()
                } else {
                    guard let user = self?.viewModel.user else { return }
                    KeychainService.shared.saveUser(
                        role: user.role,
                        token: user.jwt,
                        handler: { _ in }
                    )
                    GlobalUser.jwt = user.jwt
                    GlobalUser.role = user.role
                    self?.coordinator.authenticationDidFinish()
                }
        }.store(in: &cancellableStates)
    }
    
    private func addTargetsToTextFields() {
        for customTextFieldView in self.textFieldsView.stackView.arrangedSubviews as! [CustomTextFieldView] {
            customTextFieldView.customTextField.addTarget(self, action: #selector(textFieldAction), for: .allEditingEvents)
        }
    }
    
    @objc private func textFieldAction() {
        let customTextFieldView = self.textFieldsView.stackView.arrangedSubviews as! [CustomTextFieldView]
        viewModel.checkIfTextFieldsAreEmpty(customTextFieldsViews: customTextFieldView)
    }
}
//MARK: - LYFE CYCLE
extension CreateAccountViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardView.initialSetup()
        setupNavBar()
        setupStackView()
        setupTermsLabel()
        setupCreateAccountButton()
        addTargetsToTextFields()
        setupCancellables()
    }
}
