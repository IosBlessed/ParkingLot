//
//  CreateNewParkingLotViewModelProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 30.06.2023.
//

import Foundation

protocol CreateNewParkingLotViewModelProtocol {
    var operatesWholeWeekPublisher: Published<Bool>.Publisher { get }
    var worksAtLeastOneDayPublisher: Published<Bool>.Publisher { get }
    var createParkingLotQueryIsProcessing: Published<Bool?>.Publisher { get }
    var isParkingLotCreated: Published<Bool?>.Publisher { get }
    func operateWholeWeek()
    func parkingWorksAtLeastOneDay(state: Bool)
    func getParkingLot() -> ParkingLot?
    func createNewParkingLot(customTextFieldsStackView: [TextFieldsStackView],
                             name: String,
                             address: String,
                             workingHours: String,
                             operatingDays: [String],
                             isClosed: Bool,
                             levels: [LevelCreate])
    func updateParkingLot(
        customTextFieldsStackView: [TextFieldsStackView],
        name: String,
        address: String,
        workingHours: String,
        operatingDays: [String],
        isClosed: Bool,
        levels: [LevelCreate],
        id: Int)
}
