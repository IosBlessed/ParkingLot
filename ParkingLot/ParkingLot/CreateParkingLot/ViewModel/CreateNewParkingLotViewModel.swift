//
//  CreateNewParkingLotViewModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 30.06.2023.
//

import Foundation
import Combine

class CreateNewParkingLotViewModel: CreateNewParkingLotViewModelProtocol, ObservableObject {
    
    var service: CreateParkingLotServiceProtocol!
    var parkingLot: ParkingLot?
    
    private var createParkingLotRequest: AnyCancellable?
    private var createParkingLotModel: CreateParkingLot?
    private var editParkingLotModel: CreateParkingLot?
        
    var isParkingLotCreated: Published<Bool?>.Publisher { $_parkingLotCreated }
    @Published private var _parkingLotCreated: Bool?
    
    var createParkingLotQueryIsProcessing: Published<Bool?>.Publisher { $_createParkingLotQueryIsProcessing }
    @Published private var _createParkingLotQueryIsProcessing: Bool?

    var operatesWholeWeekPublisher: Published<Bool>.Publisher { $operatesWholeWeek }
    @Published private var operatesWholeWeek: Bool = false
    
    var worksAtLeastOneDayPublisher: Published<Bool>.Publisher { $worksAtLeastOneDay }
    @Published private var worksAtLeastOneDay: Bool = false
    
    private func validate(customTextFieldsStackView: [TextFieldsStackView]) -> Bool {
        
        customTextFieldsStackView.forEach { textField in
            textField.processTextFieldsInputData()
        }
        
        var isInputValid = true
        for textField in customTextFieldsStackView {
            let customTextFieldViews = textField.stackView.arrangedSubviews as! [CustomTextFieldView]
            customTextFieldViews.forEach { customTextFieldView in
                if customTextFieldView.customTextField.isCorrect == false {
                    isInputValid = false
                    return
                }
            }
        }
        return isInputValid
    }
    
    func createNewParkingLot(customTextFieldsStackView: [TextFieldsStackView],
                             name: String,
                             address: String,
                             workingHours: String,
                             operatingDays: [String],
                             isClosed: Bool,
                             levels: [LevelCreate]) {
        if validate(customTextFieldsStackView: customTextFieldsStackView) {

                createParkingLotModel = CreateParkingLot(
                    name: name,
                    address: address,
                    workingHours: workingHours,
                    workingDays: operatingDays,
                    closed: String(describing: isClosed),
                    operatesNonStop: String(describing:operatesWholeWeek),
                    levels: levels
                )
            requestCreateParkingLotProcessQuery()
            
        } else { return }
    }
    
    func updateParkingLot(
        customTextFieldsStackView: [TextFieldsStackView],
        name: String,
        address: String,
        workingHours: String,
        operatingDays: [String],
        isClosed: Bool,
        levels: [LevelCreate],
        id: Int) {
            if validate(customTextFieldsStackView: customTextFieldsStackView) {
                
                editParkingLotModel = CreateParkingLot(
                    name: name,
                    address: address,
                    workingHours: workingHours,
                    workingDays: operatingDays,
                    closed: String(describing: isClosed),
                    operatesNonStop: String(describing:operatesWholeWeek),
                    levels: levels
                )
                requestUpdateParkingLotProcessQuery(id: id)
            } else { return }
    }
    
    func operateWholeWeek() {
        operatesWholeWeek.toggle()
    }
    
    func parkingWorksAtLeastOneDay(state: Bool) {
        worksAtLeastOneDay = state
    }
    
    private func requestUpdateParkingLotProcessQuery(id: Int) {
        _createParkingLotQueryIsProcessing = true
        createParkingLotRequest = try! service.requestForParkingLotUpdate(parkingLot: editParkingLotModel!, id: id)
            .sink(receiveCompletion: { completion -> Void in
                self._createParkingLotQueryIsProcessing = false
                switch completion {
                case .finished:
                    return
                case .failure(_):
                    self._parkingLotCreated = false
                    self.parkingLot = nil
                }
            }, receiveValue: { parkingLot in
                self.parkingLot = parkingLot
                self._parkingLotCreated = true
            })
    }
    
    func getParkingLot() -> ParkingLot? {
        return self.parkingLot
    }
    
    private func requestCreateParkingLotProcessQuery() {
        _createParkingLotQueryIsProcessing = true
        createParkingLotRequest = try! service.requestForParkingLotCreation(parkingLot: createParkingLotModel!)
            .sink(receiveCompletion: { completion -> Void in
                self._createParkingLotQueryIsProcessing = false
                switch completion {
                case .finished:
                    return
                case .failure(_):
                    self._parkingLotCreated = false
                    self.parkingLot = nil
                }
            }, receiveValue: { parkingLot in
                self.parkingLot = parkingLot
                self._parkingLotCreated = true
            })
    }
}
