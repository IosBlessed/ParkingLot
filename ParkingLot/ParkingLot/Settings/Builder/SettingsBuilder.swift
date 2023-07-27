//
//  SettingsBuilder.swift
//  ParkingLot
//
//  Created by Никита Данилович on 19.07.2023.
//

import Foundation

struct SettingsBuilder {
    static func build() -> SettingsViewControllerProtocol {
        let view = SettingsViewController()
        return view
    }
}
