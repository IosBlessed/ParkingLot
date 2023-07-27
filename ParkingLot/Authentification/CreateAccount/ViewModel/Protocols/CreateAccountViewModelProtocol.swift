//
//  CreateAccountViewModelProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 19.06.2023.
//

import Foundation

protocol CreateAccountViewModelProtocol {
    var shouldEnableButton: Published<Bool>.Publisher { get }
    var createUserQueryIsProcessing: Published<Bool?>.Publisher { get }
    var userBeenCreated: Published<Bool?>.Publisher { get }
    var service: CreateAccountServiceProtocol! { get set }
    var user: User? { get }
    func confirmButtonWasTapped(customTextFieldView: [CustomTextFieldView])
    func checkIfTextFieldsAreEmpty(customTextFieldsViews: [CustomTextFieldView])
}
