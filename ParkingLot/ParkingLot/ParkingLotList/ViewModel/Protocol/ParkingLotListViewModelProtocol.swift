//
//  ParkingLotListViewModelProtocol.swift
//  ParkingLot
//
//  Created by Iuliana Stecalovici  on 13.07.2023.
//

import Foundation

protocol ParkingLotListViewModelProtocol: AnyObject {
    var service: ParkingLotListServiceProtocol? { get set }
    var parkingLotsListResult: Published<Result<[ParkingLot], Error>?>.Publisher { get }
    func requestParkingLots()
}
