//
//  NetworkAPI.swift
//  ParkingLot
//
//  Created by Никита Данилович on 13.06.2023.
//

import UIKit
import Combine

enum HTTPRequstMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case head = "HEAD"
}

enum HTTPResponseCode: Error {
    case badRequest
    case accessDenied
    case notFound
    case successful
    case invalidHTTPRequest
    case invalidJSONDecoder
    case uncatchableError(error: NSError)
    case userAlreadyExists

    var responseCode: Int {
        switch self {
            case .successful: return 200
            case .badRequest: return 400
            case .accessDenied: return 403
            case .notFound: return 404
            case .invalidHTTPRequest: return 406
            case .invalidJSONDecoder: return 407
            default: return 400
        }
    }
    
    var responseCodeDescription: String {
        switch self {
            case .successful: return "Successful"
            case .badRequest: return "Unfortunately your request didn't find any results!"
            case .accessDenied: return "Your access is denied!"
            case .notFound: return "Unfortunately your response comes with empty data!"
            case .invalidHTTPRequest: return "Something went wrong..."
            case .invalidJSONDecoder: return "Something went wrond, we are fixing it right now..."
        default: return "Uncatched error, please, track other"
        }
    }
}

enum URLRequestPath: String, CaseIterable {
    case createAccount = "/api/register/new"
    case login = "/auth"
    case restorePassword = "/api/restore"
    case parkingLotExtract = "/api/parkingLot/get"
    case createParkingLot = "/api/parkingLot/create"
    case getParkingSpots = "/api/parkingSpace/get/all?"
    case updateParkingLot = "/api/parkingLot/update/"
    case deleteParkingLot = "/api/parkingLot/"

    var url: String {
        return "https://backend.parking-lot-ii.app.mddinternship.com\(self.rawValue)"
    }
}

final class NetworkAPI: NetworkAPIProtocol {
    func requestForUserData(
        urlPath: String,
        httpMethod: HTTPRequstMethod,
        httpBody: Data? = nil
    ) -> AnyPublisher<Data, Error> {
        do {
            let urlRequest = try generateRequest(for: urlPath, httpMethod: httpMethod, httpBody: httpBody)
            let userRequest = URLSession.shared.dataTaskPublisher(for: urlRequest!)
                .tryMap() { incomingData -> Data in
                    guard let httpResponse = incomingData.response as? HTTPURLResponse else { throw HTTPResponseCode.badRequest }
                    switch httpResponse.statusCode {
                    case 200..<500:
                        return incomingData.data
                    default:
                        throw HTTPResponseCode.invalidHTTPRequest
                    }
                }
                .eraseToAnyPublisher()
            return userRequest
            
        } catch let error as NSError {
            // TODO: Logger to handle errors
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    public func generateRequest(
        for urlPath: String,
        _ timeoutInterval: Double = 60,
        httpMethod: HTTPRequstMethod,
        httpBody: Data? = nil,
        _ shouldHandleCookies: Bool = false
    ) throws -> URLRequest? {
        guard let url = URL(string: urlPath) else { throw HTTPResponseCode.badRequest }
        var request = URLRequest(url: url)
        if let jwt = GlobalUser.jwt {
            request.addValue(("Bearer \(jwt)"), forHTTPHeaderField: "Authorization")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        request.timeoutInterval = timeoutInterval
        request.httpShouldHandleCookies = shouldHandleCookies
        return request
    }
}
 
