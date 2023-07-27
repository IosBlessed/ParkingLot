//
//  ForgotPasswordViewModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 30.06.2023.
//

import Foundation
import Combine

final class ForgotPasswordViewModel: ObservableObject, ForgotPasswordViewModelProtocol {
    var emailTextFieldIsValid: Published<Bool>.Publisher { $_emailTextFieldIsValid }
    var receivedMessageFromSever: Published<String?>.Publisher { $_receivedMessage }
    @Published private var _emailTextFieldIsValid: Bool = false
    @Published private var _receivedMessage: String?
    private var cancellableHandler: AnyCancellable?
    var service: ForgotPasswordServiceProtocol!
    
    func processEmailTextField(textFieldsStackView: TextFieldsStackView) {
        textFieldsStackView.processTextFieldsInputData()
        let emailTextField = getEmailTextField(textFieldsStackView: textFieldsStackView)
        _emailTextFieldIsValid = emailTextField.isCorrect
    }
    
    func getEmailTextField(textFieldsStackView: TextFieldsStackView) -> CustomTextField {
        let customtextFields = textFieldsStackView.stackView.arrangedSubviews as! [CustomTextFieldView]
        let emailTextField = customtextFields.first?.customTextField ?? CustomTextField(frame: .zero)
        return emailTextField
    }
    
    func userRequestRestorePassword(email: String?) {
        guard let email else { return }
        cancellableHandler = service
            .requestSendPasswordToMail(email: email)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { restorePassswordDTO in
                    self._receivedMessage = restorePassswordDTO.message
            })
    }
}
