//
//  Auth.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

enum AuthError: Error {
    case userNotFound
    case invalidPassword
    case emailAlreadyUsed
    case creationFailed
    case unKnownError
}

import Foundation

final class AuthService {
    static let shared = AuthService()
    private let userRepository: UserRepository
    private let userSession: UserSession

    init(
        userRepository : UserRepository = UserRepository(),
        sessionManager : UserSession = UserSession.shared
    ) {
        self.userRepository = userRepository
        self.userSession = sessionManager
    }

    func login(email: String, password: String) -> Result<User, AuthError> {
        
        switch userRepository.validateUser(email: email, password: password) {
            
        case .success(let user):
            userSession.saveLoggedInUser(user: user)
            return .success(user)
            
        case .failure(let error):
            switch error {
            case .invalidCredentials:
                return .failure(.invalidPassword)
            case .userNotFound:
                return .failure(.userNotFound)
            default :
                return .failure(.unKnownError)
            }
        }
    }


    func signUp(name: String, email: String, password: String, genre: String) -> Result<User, AuthError> {

        if userRepository.emailExists(email) {
            return .failure(.emailAlreadyUsed)
        }

        let result = userRepository.createUser(email: email, password: password, profileName: name, profileImage: nil, createDate: Date(), dailyReadingGoalMinutes: nil, genre: genre)

        switch result {
        case .failure:
            return .failure(.creationFailed)

        case .success(let newUser):
            userSession.saveLoggedInUser(user: newUser)
            return .success(newUser)
        }
    }

    func logout() {
        userSession.logout()
    }
}




