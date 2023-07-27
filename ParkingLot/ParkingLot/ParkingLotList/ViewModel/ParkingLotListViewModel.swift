//
//  ParkingLotListViewModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 13.07.2023.
//

import Foundation
import Combine


final class ParkingLotListViewModel: ParkingLotListViewModelProtocol {
    
    var service: ParkingLotListServiceProtocol?
    var parkingLotsListResult: Published<Result<[ParkingLot], Error>?>.Publisher { $queryResult }
    @Published private var queryResult: Result<[ParkingLot], Error>!
    
    private var requestLotsCancellable: AnyCancellable?
    
    func requestParkingLots() {
        guard let service else { return }
        requestLotsCancellable = service
            .extractParkingLots()
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
