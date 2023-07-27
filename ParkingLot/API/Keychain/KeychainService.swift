//
//  KeychainService.swift
//  ParkingLot
//
//  Created by Никита Данилович on 17.07.2023.
//

import UIKit
import Security

enum KeychainUserKeys: String {
    case role
    case token
}

enum KeychainError: Error {
    case passwordMissMatch
    case unableToSavePassword
    case unableToProcessRequest
    case unableToUpdatePassword
    case unableToExtractPassword
    case unexpectedPasswordData
    case unableToDeletePassword
}

enum KeychainSuccess {
    case passwordSavedSuccessfully
    case passwordUpdatedSuccessfully
    case passwordDeletedSuccessfully
    case passwordExtractedSuccessfully
}

typealias PasswordDetails = [String: String]

struct KeychainServer {
    static let name: String = "md.entertainment.parkingLot"
}

class KeychainService {
    // MARK: - Properties
    private var role = ""
    private var token = Data()
    private var queryForModifications: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: KeychainServer.name
    ]
    // MARK: - Singleton
    static let shared = KeychainService()
    private init() {}
    // MARK: - Create
    func saveUser(
        role: String,
        token: String,
        handler: @escaping (Result<KeychainSuccess, KeychainError>) -> Void
    ) {
        self.role = role
        self.token = token.data(using: .utf8)!
        do {
            try saveUserToKeychain()
            handler(.success(.passwordSavedSuccessfully))
        } catch let error as KeychainError {
            handler(.failure(error))
        } catch {
            handler(.failure(.unableToProcessRequest))
        }
    }

    private func saveUserToKeychain() throws {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: role,
            kSecAttrServer as String: KeychainServer.name,
            kSecValueData as String: token
        ]
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unableToSavePassword }
    }
    // MARK: - Read
    func getUser(handler: @escaping (Result<PasswordDetails, KeychainError>) -> Void) {
        do {
            let userData = try getUserFromKeychain()
            let passwordData = userData?[kSecValueData as String] as? Data ?? Data()
            let userCredentials = [
                KeychainUserKeys.role.rawValue: userData?[kSecAttrAccount as String] as? String ?? "Unknown",
                KeychainUserKeys.token.rawValue: String(data: passwordData, encoding: .utf8) ?? "Unknown"
            ]
            handler(.success(userCredentials))
        } catch let error as KeychainError {
            handler(.failure(error))
        } catch {
            handler(.failure(.unableToProcessRequest))
        }
    }

    private func getUserFromKeychain() throws -> [String: Any]? {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: KeychainServer.name,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        var keychainData: CFTypeRef?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &keychainData)
        guard status != errSecItemNotFound else { throw KeychainError.passwordMissMatch }
        guard status == errSecSuccess else { throw KeychainError.unableToExtractPassword }
        guard let userCredentials = keychainData as? [String: Any]
        else {
            throw KeychainError.unexpectedPasswordData
        }
        return userCredentials
    }
    // MARK: - Update
    func updateUser(
        newRole role: String,
        newToken token: String,
        handler: @escaping (Result <KeychainSuccess, KeychainError>) -> Void
    ) {
        self.role = role
        self.token = token.data(using: .utf8)!
        do {
            try updateUserFromKeychain()
            handler(.success(.passwordUpdatedSuccessfully))
        } catch let error as KeychainError {
            handler(.failure(error))
        } catch {
            handler(.failure(.unableToProcessRequest))
        }
    }

    private func updateUserFromKeychain() throws {
        let newAttributes: [String: Any] = [
            kSecAttrAccount as String: role,
            kSecValueData as String: token
        ]
        let status = SecItemUpdate(queryForModifications as CFDictionary, newAttributes as CFDictionary)
        guard status != errSecItemNotFound else { throw KeychainError.passwordMissMatch}
        guard status == errSecSuccess else { throw KeychainError.unableToUpdatePassword }
    }
    // MARK: - Delete
    func deleteUser(handler: @escaping (Result<KeychainSuccess, KeychainError>) -> Void) {
        do {
            try deleteUserFromKeychain()
            handler(.success(.passwordDeletedSuccessfully))
        } catch let error as KeychainError {
            handler(.failure(error))
        } catch {
            handler(.failure(.unableToProcessRequest))
        }
    }

    private func deleteUserFromKeychain() throws {
        let status = SecItemDelete(queryForModifications as CFDictionary)
        guard status != errSecItemNotFound else { throw KeychainError.passwordMissMatch}
        guard status == errSecSuccess else { throw KeychainError.unableToDeletePassword }
    }
}
