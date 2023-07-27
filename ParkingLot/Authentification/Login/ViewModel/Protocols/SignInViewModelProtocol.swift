//
//  SignInViewModelProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 26.06.2023.
//

import Foundation

protocol SignInViewModelProtocol: AnyObject {
    var textFieldsValidationPublisher: Published<Bool>.Publisher { get }
    var userAuthenticated: Published<Bool?>.Publisher { get }
    var user: User? { get set }
    var service: SignInServiceProtocol! { get set }
    func shouldProcessTextFields(customTextFieldsStackView: TextFieldsStackView)
    func authenticateUser()
}
