//
//  ParkingSpotsViewModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 16.07.2023.
//

import Foundation
import Combine

final class ParkingSpotsViewModel: ParkingSpotsViewModelProtocol {
    var service: ParkingSpotsServiceProtocol!
    
    var parkingLot: Published<ParkingLot?>.Publisher { $_parkingLot }
    @Published var _parkingLot: ParkingLot?
    
    var parkingSpotsListResult: Published<Result<[ParkingSpot], Error>?>.Publisher { $queryResult }
    @Published private var queryResult: Result<[ParkingSpot], Error>!
    
    private var requestSpotsCancellable: AnyCancellable?
    
    func requestForParkingSpots(parkingLevel: Int) {
        let parkingLevelId = _parkingLot?.levels[parkingLevel].id ?? 0
        requestSpotsCancellable = service
            .extractParkingSpots(parkingLotId: _parkingLot?.id ?? 0, parkingLevelId: parkingLevelId)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        return
                    case .failure(let error):
                        self.queryResult = .failure(error)
                    }
                },
                receiveValue: { [weak self] parkingLots in
                    self?.queryResult = .success(parkingLots)
                }
            )
    }
}

protocol ParkingSpotsViewModelProtocol: AnyObject {
    var parkingSpotsListResult: Published<Result<[ParkingSpot], Error>?>.Publisher { get }
    var parkingLot: Published<ParkingLot?>.Publisher { get }
    
    func requestForParkingSpots(parkingLevel: Int)
}
