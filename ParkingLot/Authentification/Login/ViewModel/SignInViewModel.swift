//
//  SignInViewModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 26.06.2023.
//

import UIKit
import Combine

class SignInViewModel:
    SignInViewModelProtocol,
    CustomTextFieldProtocol,
    ObservableObject
{
    
    var textFieldsValidationPublisher: Published<Bool>.Publisher { $textFieldsAreValid }
    var service: SignInServiceProtocol!
    var userAuthenticated: Published<Bool?>.Publisher { $_userAuthenticated }
    var user: User?
    @Published private var _userAuthenticated: Bool?
    @Published private var textFieldsAreValid: Bool = true
    private var cancellableHandler: AnyCancellable?
    var customTextFieldViews = [CustomTextFieldView]()
    
    func shouldProcessTextFields(customTextFieldsStackView: TextFieldsStackView) {
        self.customTextFieldViews = customTextFieldsStackView
            .stackView
            .arrangedSubviews as! [CustomTextFieldView]
        customTextFieldsStackView.processTextFieldsInputData()
        let customTextFields = customTextFieldsStackView.stackView.arrangedSubviews as! [CustomTextFieldView]
        textFieldsAreValid = customTextFields.contains { customTextFieldView in
            customTextFieldView.customTextField.isCorrect == false
        }
    }
    
    func authenticateUser() {
        let user = UserAuthenticate(
            email: getTextFieldInput(by: .email),
            password: getTextFieldInput(by: .password)
        )
        cancellableHandler = service
            .authenticateUserRequest(user: user)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case .failure(_):
                    self._userAuthenticated = false
                    self.user = nil
                }
            }, receiveValue: { user in
                self.user = user
                self._userAuthenticated = true
            }
            )
    }
}
