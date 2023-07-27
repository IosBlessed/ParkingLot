//
//  LogInService.swift
//  ParkingLot
//
//  Created by Никита Данилович on 03.07.2023.
//

import Foundation
import Combine

protocol SignInServiceProtocol: AnyObject {
    var networkAPI: NetworkAPIProtocol { get set }
    func authenticateUserRequest(user: UserAuthenticate) -> Future<User, Error>
    func decodeUserIncomingData(_ data: Data) throws -> User
}

final class SignInService: SignInServiceProtocol {
    
    var networkAPI: NetworkAPIProtocol = NetworkAPI()
    private var cancellableUser: AnyCancellable?
    
    func authenticateUserRequest(user: UserAuthenticate) -> Future<User, Error> {
        let userEncoded = try! JSONEncoder().encode(user)
        return Future { [weak self] response in
            guard let self else { return }
            self.cancellableUser = self.networkAPI.requestForUserData(
                urlPath: URLRequestPath.login.url,
                httpMethod: .post,
                httpBody: userEncoded
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    response(.failure(error))
                }
            }, receiveValue: { data in
                do {
                    let user = try self.decodeUserIncomingData(data)
                    response(.success(user))
                } catch {
                    response(.failure(ErrorHandler(message: "Wrong credentials!")))
                }
            })
        }
    }
    
    func decodeUserIncomingData(_ data: Data) throws -> User {
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            throw HTTPResponseCode.invalidJSONDecoder
        }
    }
}
