//
//  NetworkProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 13.06.2023.
//

import Foundation
import Combine

protocol NetworkAPIProtocol: AnyObject {
    func requestForUserData(
        urlPath: String,
        httpMethod: HTTPRequstMethod,
        httpBody: Data?
    ) -> AnyPublisher<Data, Error>
}
