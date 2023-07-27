//
//  CreateParkingLotService.swift
//  ParkingLot
//
//  Created by Никита Данилович on 12.07.2023.
//

import Foundation
import Combine

protocol CreateParkingLotServiceProtocol: AnyObject {
    var networkRequest: NetworkAPIProtocol { get set }
    func requestForParkingLotCreation(parkingLot: CreateParkingLot) throws -> AnyPublisher<ParkingLot, Error>
    func decodeUserIncomingData(_ data: Data) throws -> ParkingLot
    func requestForParkingLotUpdate(parkingLot: CreateParkingLot, id: Int) throws -> AnyPublisher<ParkingLot, Error>
}

final class CreateParkingLotService: CreateParkingLotServiceProtocol {
    
    var networkRequest: NetworkAPIProtocol = NetworkAPI()
    private var createParkingLotCancellabel: AnyCancellable?
    
    func requestForParkingLotCreation(parkingLot: CreateParkingLot) throws -> AnyPublisher<ParkingLot, Error> {
        let userData = try JSONEncoder().encode(parkingLot)
        return networkRequest.requestForUserData(
            urlPath: URLRequestPath.createParkingLot.url,
            httpMethod: .post,
            httpBody: userData
        )
        .tryMap { [weak self] data in
            let parkingLot = try self?.decodeUserIncomingData(data)
            guard let parkingLot else { return ParkingLot(id: 0, name: " ", address: " ", workingHours: " ", workingDays: [], levels: [], operatesNonStop: true, isClosed: true, levelOfOccupancy: 0, countOfAccessibleParkingSpots: 0, countOfFamilyFriendlyParkingSpots: 0)}
            return parkingLot
        }
        .eraseToAnyPublisher()
    }
    
    func requestForParkingLotUpdate(parkingLot: CreateParkingLot, id: Int) throws -> AnyPublisher<ParkingLot, Error> {
        let userData = try JSONEncoder().encode(parkingLot)
        
        return networkRequest.requestForUserData(
            urlPath: URLRequestPath.updateParkingLot.url + String(id),
            httpMethod: .put,
            httpBody: userData
        )
        .tryMap { [weak self] data in
            let parkingLot = try self?.decodeUserIncomingData(data)
            guard let parkingLot else { return ParkingLot(id: 0, name: " ", address: " ", workingHours: " ", workingDays: [], levels: [], operatesNonStop: true, isClosed: true, levelOfOccupancy: 0, countOfAccessibleParkingSpots: 0, countOfFamilyFriendlyParkingSpots: 0)}
            return parkingLot
        }
        .eraseToAnyPublisher()
    }
    
    func decodeUserIncomingData(_ data: Data) throws -> ParkingLot {
        do {
            let jsonDecodedUser = try JSONDecoder().decode(ParkingLot.self, from: data)
            return jsonDecodedUser
        } catch {
            throw HTTPResponseCode.invalidJSONDecoder
        }
    }
}
