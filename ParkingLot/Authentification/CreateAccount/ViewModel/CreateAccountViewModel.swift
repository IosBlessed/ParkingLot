//
//  CreateAccountViewModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 19.06.2023.
//

import Foundation
import Combine

final class CreateAccountViewModel: CreateAccountViewModelProtocol, CustomTextFieldProtocol {
    // MARK: - Publishers
    var shouldEnableButton: Published<Bool>.Publisher { $textFieldsAreEmpty }
    var createUserQueryIsProcessing: Published<Bool?>.Publisher { $_createUserQueryIsProcessing }
    var userBeenCreated: Published<Bool?>.Publisher { $_userBeenCreated }
    // MARK: - Published
    @Published private var textFieldsAreEmpty: Bool = true
    @Published private var _createUserQueryIsProcessing: Bool?
    @Published private var _userBeenCreated: Bool?
    var customTextFieldViews = [CustomTextFieldView]()
    private var createUserRequest: AnyCancellable?
    // MARK: - Properties
    var service: CreateAccountServiceProtocol!
    private var fieldErrorTupple = (
        name: TextFieldsErrors.nameLength,
        email: TextFieldsErrors.email,
        password: TextFieldsErrors.passwordLength,
        phone: TextFieldsErrors.phoneLength
    )
    var user: User?
    // MARK: - Behaviour
    private func isValidPhone(_ phone: String) -> Bool {
        let passwordLengthSuitable = phone.count == TextFieldsOptions.phoneNumberLength
        let passwordIsCorrect = TextFieldsOptions.phoneRegex.matches(phone)
        if passwordLengthSuitable {
            if passwordIsCorrect {
                return true
            } else {
                self.fieldErrorTupple.phone = TextFieldsErrors.phoneStartFromZeroAndContainDigits
            }
        } else {
            self.fieldErrorTupple.phone = TextFieldsErrors.phoneLength
        }
        return false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let isValidPattern = TextFieldsOptions.emailRegex.matches(email)
        let isSuitableLength = email.count >= 5 && email.count <= 320
        if isSuitableLength {
            if isValidPattern {
                return true
            } else {
                self.fieldErrorTupple.email = TextFieldsErrors.email
            }
        } else {
            self.fieldErrorTupple.email = TextFieldsErrors.emailLength
        }
        return false
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let minLength = TextFieldsOptions.passwordMinimumLength
        let maxLength = TextFieldsOptions.passwordMaximumLength
        let passwordSymbolsAreCorrect = TextFieldsOptions.passwordRegex.matches(password)
        if password.count >= minLength && password.count <= maxLength {
            if passwordSymbolsAreCorrect { return true }
            else { self.fieldErrorTupple.password = TextFieldsErrors.passwordSpecialSymbols }
        } else {
            self.fieldErrorTupple.password = TextFieldsErrors.passwordLength
        }
        return false
    }
    
    private func isValidName(_ name: String) -> Bool {
        let nameSpecialSymbolsAreCorrect = TextFieldsOptions.nameRegex.matches(name)
        let minLength = TextFieldsOptions.nameMinimumLength
        let maxLength = TextFieldsOptions.nameMaximumLength
        if name.count >= minLength  && name.count <= maxLength {
            if nameSpecialSymbolsAreCorrect { return true }
            else { self.fieldErrorTupple.name = TextFieldsErrors.nameSpecialSymbols }
        } else {
            self.fieldErrorTupple.name = TextFieldsErrors.nameLength
        }
        return false
    }
    
    private func validateInputFields(customTextFieldView: [CustomTextFieldView]) -> Bool {
        for customTextFieldView in customTextFieldView {
            let curentTextFieldText = customTextFieldView.customTextField.text ?? ""
            switch customTextFieldView.customTextField.restorationIdentifier! {
            case TextFieldsIdentifier.name.rawValue:
                let isValidName = isValidName(curentTextFieldText)
                customTextFieldView.setupErrorLabelText(with: fieldErrorTupple.name.rawValue)
                customTextFieldView.isCorrect = isValidName
                
            case TextFieldsIdentifier.phoneNumber.rawValue:
                let isValidPhone = isValidPhone(curentTextFieldText)
                customTextFieldView.setupErrorLabelText(with: fieldErrorTupple.phone.rawValue)
                customTextFieldView.isCorrect = isValidPhone
                
            case TextFieldsIdentifier.email.rawValue:
                let isValidEmail = isValidEmail(curentTextFieldText)
                customTextFieldView.setupErrorLabelText(with: fieldErrorTupple.email.rawValue)
                customTextFieldView.isCorrect = isValidEmail
                
            case  TextFieldsIdentifier.password.rawValue:
                let isValidPassword = isValidPassword(curentTextFieldText)
                customTextFieldView.setupErrorLabelText(with: fieldErrorTupple.password.rawValue)
                customTextFieldView.isCorrect = isValidPassword
                
            default: return false
            }
        }
        return !customTextFieldView.contains { $0.isCorrect == false }
    }
    // MARK: - Implementation
    func confirmButtonWasTapped(customTextFieldView: [CustomTextFieldView]) {
        self.customTextFieldViews = customTextFieldView
        let isValidFields = validateInputFields(customTextFieldView: customTextFieldView)
        if !isValidFields { return }
        requestServiceToProcessQuery()
    }
    private func requestServiceToProcessQuery() {
        _createUserQueryIsProcessing = true
        let createUserModel = UserCreate(
            name: getTextFieldInput(by: .name),
            email: getTextFieldInput(by: .email),
            password: getTextFieldInput(by: .password),
            phone: getTextFieldInput(by: .phoneNumber)
        )
       createUserRequest = try! service.requestForUserCreation(user: createUserModel)
            .sink(receiveCompletion: { completion -> Void in
                self._createUserQueryIsProcessing = false
                switch completion {
                case .finished:
                    return
                case .failure(_):
                    self._userBeenCreated = false
                }
        }, receiveValue: { user in
            self.user = user
            self._userBeenCreated = true
        })
    }
    
    func checkIfTextFieldsAreEmpty(customTextFieldsViews: [CustomTextFieldView]) {
        self.textFieldsAreEmpty = customTextFieldsViews.contains { $0.customTextField.text == "" }
        customTextFieldsViews.forEach { customTextFieldView in
            guard let text = customTextFieldView.customTextField.text else { return }
            if text.isEmpty {
                customTextFieldView.customTextField.isCorrect = true
            }
        }
    }
}
