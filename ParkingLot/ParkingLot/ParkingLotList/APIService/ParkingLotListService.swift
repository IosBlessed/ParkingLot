//
//  ParkingLotListService.swift
//  ParkingLot
//
//  Created by Никита Данилович on 17.07.2023.
//

import Foundation
import Combine

protocol ParkingLotListServiceProtocol: AnyObject {
    var networkAPI: NetworkAPIProtocol { get set }
    var receiveParkingLotCancellable: AnyCancellable? { get set }
    func extractParkingLots() -> AnyPublisher<[ParkingLot], Error>
}

final class ParkingLotListService: ParkingLotListServiceProtocol {
    
    var networkAPI: NetworkAPIProtocol = NetworkAPI()
    var receiveParkingLotCancellable: AnyCancellable?
    
    func extractParkingLots() -> AnyPublisher<[ParkingLot], Error> {
        return networkAPI.requestForUserData(
            urlPath: URLRequestPath.parkingLotExtract.url,
            httpMethod: .get,
            httpBody: nil
        ).tryMap { data in
            do {
               return try JSONDecoder().decode([ParkingLot].self, from: data)
            } catch {
                throw HTTPResponseCode.invalidJSONDecoder
            }
        }.eraseToAnyPublisher()
    }
}
