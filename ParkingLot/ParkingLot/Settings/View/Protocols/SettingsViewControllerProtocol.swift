//
//  SettingsViewControllerProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 19.07.2023.
//

import Foundation

protocol SettingsViewControllerProtocol: AnyObject {
    var coordinator: ParkingLotCoordinatorProtocol! { get set }
}
