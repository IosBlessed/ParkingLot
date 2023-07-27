//
//  EditParkingLotViewModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 23.07.2023.
//

import Foundation
import Combine

protocol EditParkingLotViewModelProtocol {
    func deleteParkingLot(with id: Int)
    var deletionResult: Published<Bool?>.Publisher { get }
}

class EditParkingLotViewModel:  EditParkingLotViewModelProtocol {
    
    var service: EditParkingLotServiceProtocol!
    var deleteParkingLotCancellable: AnyCancellable?
    
    var deletionResult: Published<Bool?>.Publisher { $queryResult }
    @Published private var queryResult: Bool? = nil
    
    func deleteParkingLot(with id: Int) {
        deleteParkingLotCancellable = service.deleteParkingLot(with: id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.queryResult = true
                case .failure(_):
                    self.queryResult = false
                }
            }, receiveValue: {
            })
    }
}
