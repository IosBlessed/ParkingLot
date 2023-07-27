//
//  AuthenticationViewController.swift
//  ParkingLot
//
//  Created by Никита Данилович on 13.06.2023.
//

import UIKit

class AuthenticationViewController: UIViewController, AuthenticationViewControllerProtocol {
    // MARK: - Outlets
    @IBOutlet private weak var createAccountButton: UIButton! {
        didSet {
            createAccountButton.activateShadowMode()
        }
    }
    @IBOutlet private weak var signInButton: UIButton! {
        didSet {
            signInButton.activateShadowMode()
        }
    }
    @IBOutlet private weak var gifImage: UIImageView!
    // MARK: - Properties
    var coordinator: AuthentificationCoordinatorProtocol!
    // MARK: - Behaviour
    func checkUserPersistence() {
        KeychainService.shared.getUser { [weak self] result in
            switch result {
            case .success(let passwordDetails):
                if !passwordDetails.isEmpty {
                    GlobalUser.role = passwordDetails[KeychainUserKeys.role.rawValue] ?? ""
                    GlobalUser.jwt = passwordDetails[KeychainUserKeys.token.rawValue] ?? ""
                    self?.coordinator.authenticationDidFinish()
                }
            case .failure(_):
                return
            }
        }
    }
    // MARK: - Action
    @IBAction private func createAccount(_ sender: Any) {
        createAccountButton.animateButtonWhenTapping()
        coordinator.openCreateAccScreen()
    }
    
    @IBAction private func signin(_ sender: Any) {
        signInButton.animateButtonWhenTapping()
        coordinator.openSignInScreen()
    }
}

// MARK: - LIFE CYCLE
extension AuthenticationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        navigationController?.navigationBar.tintColor = .black
        view.backgroundColor = CustomSystemColors.primary
        setUpGifImage()
        checkUserPersistence()
    }
}

// MARK: - GIF IMAGE SETUP

extension AuthenticationViewController {
    private func setUpGifImage() {
        let gif = UIImage.gifImageWithName("gif")
        self.gifImage.image = gif
    }
}
