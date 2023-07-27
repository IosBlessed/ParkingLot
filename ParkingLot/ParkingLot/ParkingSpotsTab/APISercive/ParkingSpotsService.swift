//
//  ParkingSpotsService.swift
//  ParkingLot
//
//  Created by Никита Данилович on 16.07.2023.
//

import Foundation
import Combine

final class ParkingSpotsService: ParkingSpotsServiceProtocol {
    private var networkAPI: NetworkAPIProtocol = NetworkAPI()
    
    func extractParkingSpots(parkingLotId: Int, parkingLevelId: Int) -> AnyPublisher<[ParkingSpot], Error> {
        return networkAPI.requestForUserData(
            urlPath: URLRequestPath.getParkingSpots.url + "lot_id=" + String(parkingLotId) + "&level_id=" + String(parkingLevelId),
            httpMethod: .get,
            httpBody: nil
        ).tryMap { data in
            do {
               return try JSONDecoder().decode([ParkingSpot].self, from: data)
            } catch {
                throw HTTPResponseCode.invalidJSONDecoder
            }
        }.eraseToAnyPublisher()
    }
}

protocol ParkingSpotsServiceProtocol: AnyObject {
    func extractParkingSpots(parkingLotId: Int, parkingLevelId: Int) -> AnyPublisher<[ParkingSpot], Error>
}
