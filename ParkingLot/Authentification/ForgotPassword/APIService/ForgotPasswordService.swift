//
//  ForgotPasswordService.swift
//  ParkingLot
//
//  Created by Никита Данилович on 11.07.2023.
//

import Foundation
import Combine

protocol ForgotPasswordServiceProtocol: AnyObject {
    var networkAPI: NetworkAPIProtocol { get set }
    func requestSendPasswordToMail(email: String) -> Future<RestorePasswordDTO,Error>
    func decodeIncomingMessage(_ data: Data) throws -> RestorePasswordDTO
}

final class ForgotPasswordService: ForgotPasswordServiceProtocol {
    var networkAPI: NetworkAPIProtocol = NetworkAPI()
    private var cancellableRequest: AnyCancellable!
    func requestSendPasswordToMail(email: String) -> Future<RestorePasswordDTO,Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            let userEmail = try! JSONEncoder().encode(email)
            self.cancellableRequest = networkAPI.requestForUserData(
                urlPath: URLRequestPath.restorePassword.url,
                httpMethod: .post,
                httpBody: userEmail
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    return promise(.failure(error))
                }
            }, receiveValue: { data in
                let receivedMessageDTO = try! self.decodeIncomingMessage(data)
                promise(.success(receivedMessageDTO))
            })
        }
    }
    
    func decodeIncomingMessage(_ data: Data) throws -> RestorePasswordDTO {
        do {
            let receivedMessage = try JSONDecoder().decode(RestorePasswordDTO.self, from: data)
            return receivedMessage
        } catch {
            throw HTTPResponseCode.invalidJSONDecoder
        }
    }
}
