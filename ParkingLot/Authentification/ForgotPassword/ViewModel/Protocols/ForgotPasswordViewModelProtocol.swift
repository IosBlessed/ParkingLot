//
//  ForgotPasswordViewModelProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 07.07.2023.
//

import Foundation

protocol ForgotPasswordViewModelProtocol: AnyObject {
    var service: ForgotPasswordServiceProtocol! { get set }
    var emailTextFieldIsValid: Published<Bool>.Publisher { get }
    var receivedMessageFromSever: Published<String?>.Publisher { get }
    func processEmailTextField(textFieldsStackView: TextFieldsStackView)
    func userRequestRestorePassword(email: String?)
    func getEmailTextField(textFieldsStackView: TextFieldsStackView) -> CustomTextField
}
