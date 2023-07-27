//
//  TextFieldsViewModelProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 26.06.2023.
//

import Foundation

protocol TextFieldsViewModelProtocol: AnyObject {
    var textFields: [CustomTextFieldView] { get set }
    func validateTextFields()
    func textFieldsAreNotEmpty() -> Bool
    func clearTextFields()
}
