//
//  CustomTextFieldProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 04.07.2023.
//

import Foundation

protocol CustomTextFieldProtocol: AnyObject {
    var customTextFieldViews: [CustomTextFieldView] { get set }
    func getTextFieldInput(by identifier: TextFieldsIdentifier) -> String
}

extension CustomTextFieldProtocol {
    func getTextFieldInput(by identifier: TextFieldsIdentifier) -> String {
        return customTextFieldViews
            .first(
                where: { $0.customTextField.restorationIdentifier == identifier.rawValue }
            )?
            .customTextField
            .text ?? ""
    }
}
