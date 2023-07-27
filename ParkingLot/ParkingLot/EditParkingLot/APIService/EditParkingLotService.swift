//
//  EditParkingLotService.swift
//  ParkingLot
//
//  Created by Никита Данилович on 23.07.2023.
//

import Foundation
import Combine

protocol EditParkingLotServiceProtocol {
    func deleteParkingLot(with id: Int) -> AnyPublisher<Void, Error>
}

class EditParkingLotService: EditParkingLotServiceProtocol {
    private var network:NetworkAPIProtocol = NetworkAPI()
    
    func deleteParkingLot(with id: Int) -> AnyPublisher<Void, Error> {
        return network.requestForUserData(
            urlPath: URLRequestPath.deleteParkingLot.url + String(id) + "/deleteParkingLot",
            httpMethod: .delete,
            httpBody: nil)
        .map { _ in () }
        .eraseToAnyPublisher()
    }
}
