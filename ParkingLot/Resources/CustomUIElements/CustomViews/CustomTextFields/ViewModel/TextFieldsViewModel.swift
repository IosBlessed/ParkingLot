//
//  CustomTextFieldsViewModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 26.06.2023.
//

import Foundation
import Combine

final class TextFieldsViewModel: NSObject, TextFieldsViewModelProtocol {
    var textFields = [CustomTextFieldView]()
    
    private var fieldErrorTupple = (
        name: TextFieldsErrors.nameLength,
        email: TextFieldsErrors.email,
        password: TextFieldsErrors.passwordLength,
        phone: TextFieldsErrors.phoneLength,
        adressName: TextFieldsErrors.parkingLotNameAdressLength,
        nrOfParkingSpots: TextFieldsErrors.nrOfParkingSpots
    )
    
    private func adressNameTextFieldIsValid(for text: String) -> Bool {
        let minLength = TextFieldsOptions.adressNameMinimumLength
        let maxLength = TextFieldsOptions.adressNameMaximumLength
        let suitableLength = (text.count >= minLength && text.count <= maxLength)
            
        if suitableLength {
            if doesNotContainEmoji(text) {
                if doesNotContainRussianText(text) {
                    return true
                } else {
                    self.fieldErrorTupple.adressName = TextFieldsErrors.parkingLotNameAdressEmoji
                }
            } else {
                self.fieldErrorTupple.adressName = TextFieldsErrors.parkingLotNameAdressRussian
            }
        }
        return false
    }
    
    func doesNotContainEmoji(_ text: String) -> Bool {
        for char in text {
                if isEmoji(char) {
                    return false // Contains emoji, return false
                }
            }
        return true
    }
    
    func isEmoji(_ character: Character) -> Bool {
        let scalarValue = character.unicodeScalars.first!.value
        return (scalarValue >= 0x1F600 && scalarValue <= 0x1F64F) || // Emoticons
               (scalarValue >= 0x1F300 && scalarValue <= 0x1F5FF) || // Miscellaneous Symbols and Pictographs
               (scalarValue >= 0x1F680 && scalarValue <= 0x1F6FF) || // Transport and Map Symbols
               (scalarValue >= 0x2600 && scalarValue <= 0x26FF) || // Miscellaneous Symbols
               (scalarValue >= 0x2700 && scalarValue <= 0x27BF) // Dingbats
    }

    func doesNotContainRussianText(_ text: String) -> Bool {
        return text.range(of: TextFieldsOptions.emailNameRussianRegex, options: .regularExpression) == nil
    }
    
    private func nrOfParkingSpotsTextFieldIsValid(for text: String) -> Bool {
        let nrOfParkingSpotsSymbolsAreCorrect = TextFieldsOptions.nrOfParkingRegex.matches(text)
        let isValid  = nrOfParkingSpotsSymbolsAreCorrect ? true : false
        return isValid
    }
    
    private func emailTextFieldIsValid(for text: String) -> Bool {
        let isValidPattern = TextFieldsOptions.emailRegex.matches(text)
        let isSuitableLength = text.count >= 5 && text.count <= 320
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
    
    private func passwordTextFieldIsValid(for text: String) -> Bool {
        let minLength = TextFieldsOptions.passwordMinimumLength
        let maxLength = TextFieldsOptions.passwordMaximumLength
        let passwordSymbolsAreCorrect = TextFieldsOptions.passwordRegex.matches(text)
        if text.count >= minLength && text.count <= maxLength {
            if passwordSymbolsAreCorrect { return true }
            else { self.fieldErrorTupple.password = TextFieldsErrors.passwordSpecialSymbols }
        } else {
            self.fieldErrorTupple.password = TextFieldsErrors.passwordLength
        }
        return false
    }
    
    private func phoneTextFieldIsValid(for text: String) -> Bool {
        let phoneLengthSuitable = text.count == TextFieldsOptions.phoneNumberLength
        let phoneIsValid = TextFieldsOptions.phoneRegex.matches(text)
        if phoneLengthSuitable {
            if phoneIsValid {
                return true
            } else {
                self.fieldErrorTupple.phone = TextFieldsErrors.phoneStartFromZeroAndContainDigits
            }
        } else {
            self.fieldErrorTupple.phone = TextFieldsErrors.phoneLength
        }
        return false
    }
    
    private func nameTextFieldIsValid(for text: String) -> Bool {
        let nameSpecialSymbolsAreCorrect = TextFieldsOptions.nameRegex.matches(text)
        let minLength = TextFieldsOptions.nameMinimumLength
        let maxLength = TextFieldsOptions.nameMaximumLength
        if text.count >= minLength  && text.count <= maxLength {
            if nameSpecialSymbolsAreCorrect { return true }
            else { self.fieldErrorTupple.name = TextFieldsErrors.nameSpecialSymbols }
        } else {
            self.fieldErrorTupple.name = TextFieldsErrors.nameLength
        }
        return false
    }
    
    private func getTextFieldViewByIdentifier(with identifier: TextFieldsIdentifier) -> CustomTextFieldView? {
        return textFields.first { customTextFieldView in
            customTextFieldView.customTextField.restorationIdentifier == identifier.rawValue
        }
    }
    
    private func validateTextFieldIfExists(customTextFieldView: CustomTextFieldView?) {
        guard let customTextFieldView else { return }
        let text = customTextFieldView.customTextField.text ?? ""
        switch customTextFieldView.customTextField.restorationIdentifier {
            // EMAIL VERIFICATION
        case TextFieldsIdentifier.email.rawValue:
            let isValid = emailTextFieldIsValid(for: text)
            self.setupTextFieldEnvironment(customTextFieldView, isValid, fieldErrorTupple.email)
            // PASSWORD VERIFICATION
        case TextFieldsIdentifier.password.rawValue:
            let isValid = passwordTextFieldIsValid(for: text)
            self.setupTextFieldEnvironment(customTextFieldView, isValid, fieldErrorTupple.password)
            // PHONE NUMBER VERIFICATION
        case TextFieldsIdentifier.phoneNumber.rawValue:
            let isValid = phoneTextFieldIsValid(for: text)
            self.setupTextFieldEnvironment(customTextFieldView, isValid, fieldErrorTupple.phone)
            // NAME VERIFICATION
        case TextFieldsIdentifier.name.rawValue:
            let isValid = nameTextFieldIsValid(for: text)
            self.setupTextFieldEnvironment(customTextFieldView, isValid, fieldErrorTupple.name)
            // PARKINGLOT NAME VERIFICATION
        case TextFieldsIdentifier.parkingLotName.rawValue:
            let isValid = adressNameTextFieldIsValid(for: text)
            self.setupTextFieldEnvironment(customTextFieldView, isValid, fieldErrorTupple.adressName)
            // PARKINGLOT ADRESS VERIFICATION
        case TextFieldsIdentifier.parkingLotAddress.rawValue:
            let isValid = adressNameTextFieldIsValid(for: text)
            self.setupTextFieldEnvironment(customTextFieldView, isValid, fieldErrorTupple.adressName)
            // NR OF PARKING SPOTS VERIFICATION
        case TextFieldsIdentifier.nrOfParkingSpots.rawValue:
            let isValid = nrOfParkingSpotsTextFieldIsValid(for: text)
            self.setupTextFieldEnvironment(customTextFieldView, isValid, fieldErrorTupple.nrOfParkingSpots)
        default: return
        }
    }
    
    private func setupTextFieldEnvironment(
        _ customTextFieldView: CustomTextFieldView,
        _ flag: Bool,
        _ errorText: TextFieldsErrors
    ) {
        customTextFieldView.setupErrorLabelText(with: errorText.rawValue)
        customTextFieldView.customTextField.isCorrect = flag
    }
    
    func validateTextFields() {
        // TODO: Check if they are existing
        textFields.forEach { customTextFieldView in
            self.validateTextFieldIfExists(customTextFieldView: customTextFieldView)
        }
    }
    
    func clearTextFields() {
           textFields.forEach { customTextFieldView in
               customTextFieldView.customTextField.text = ""
           }
    }
    
    func textFieldsAreNotEmpty() -> Bool {
        var textFieldContainsEmpty: [Bool] = []
        textFields.forEach { customTextFieldView in
            let textFieldIsEmpty = customTextFieldView.customTextField.text == ""
            textFieldContainsEmpty.append(textFieldIsEmpty)
            if textFieldIsEmpty {
                customTextFieldView.customTextField.isCorrect = true
            }
        }
        return textFieldContainsEmpty.contains { $0 == true }
    }
}
