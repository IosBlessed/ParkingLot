//
//  CreateAccountService.swift
//  ParkingLot
//
//  Created by Никита Данилович on 03.07.2023.
//

import Foundation
import Combine

protocol CreateAccountServiceProtocol: AnyObject {
    var networkRequest: NetworkAPIProtocol { get set }
    func requestForUserCreation(user: UserCreate) throws -> Future<User, Error>
    func decodeUserIncomingData(_ data: Data) throws -> User
}

final class CreateAccountService: CreateAccountServiceProtocol {
    
    var networkRequest: NetworkAPIProtocol = NetworkAPI()
    private var createUserCancellabel: AnyCancellable?
    
    func requestForUserCreation(user: UserCreate) throws -> Future<User, Error> {
        let userData = try JSONEncoder().encode(user)
        return Future { [weak self] response in
            guard let self else { return }
            self.createUserCancellabel = self.networkRequest.requestForUserData(
                urlPath: URLRequestPath.createAccount.url,
                httpMethod: .post,
                httpBody: userData
            )
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        response(.failure(error))
                    case .finished:
                       return
                    }
                } receiveValue: { data in
                    do {
                        let user = try self.decodeUserIncomingData(data)
                        response(.success(user))
                    } catch {
                        response(.failure(ErrorHandler(message: "Untracked error in create account module!")))
                    }
                }
        }
    }
    
    func decodeUserIncomingData(_ data: Data) throws -> User {
        do {
            let jsonDecodedUser = try JSONDecoder().decode(User.self, from: data)
            return jsonDecodedUser
        } catch {
            throw HTTPResponseCode.invalidJSONDecoder
        }
    }
}
