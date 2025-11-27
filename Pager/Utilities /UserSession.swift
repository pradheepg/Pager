//
//  UserSession.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import Foundation

final class UserSession {
    static let shared = UserSession()
    var currentUser: User?
    var authToken: String?
    private let userRepository = UserRepository()
        
    func isLoggedIn() -> Bool {
        return currentUser != nil && authToken != nil
    }
    
    func logout() {
        currentUser = nil
        authToken = nil
        clearSessionKeychain()
    }
    
    func saveLoggedInUser(user: User) {
        currentUser = user
        authToken = user.userId?.uuidString
        if let authToken = authToken {
            KeychainHelper.shared.saveString(authToken, service: KeychainKeys.serviceAuth, account: KeychainKeys.accountUserID)
        }
    }
    
    func loadSession() -> Bool {
        guard let token = KeychainHelper.shared.loadString(
            service: KeychainKeys.serviceAuth,
            account: KeychainKeys.accountUserID
        ) else { return false }

        authToken = token
        
        if let uuid = UUID(uuidString: token) {
            switch userRepository.fetchUser(by: uuid) {
            case .success(let user):
                currentUser = user
                return true
            case .failure:
                currentUser = nil
            }
        }
        return false
    }
    func clearSessionKeychain() {
        KeychainHelper.shared.delete(
            service: KeychainKeys.serviceAuth,
            account: KeychainKeys.accountUserID
        )
    }
}
