//
//  LoginViewModel.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import Foundation

final class LoginViewModel {

    var onLoginSuccess: ((User) -> Void)?
    var onLoginFailure: ((String) -> Void)?
    var onNavigateToSignup: (() -> Void)?

    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            onLoginFailure?("Email and password cannot be empty.")
            return
        }
        let result = AuthService.shared.login(email: email, password: password)

        switch result {
        case .success(let user):
//            UserSession.shared.saveLoggedInUser(user: user)
            self.onLoginSuccess?(user)
        case .failure(let error):
            switch error {
            case .userNotFound:
                self.onLoginFailure?("Email Not Found!")
            case .invalidPassword:
                self.onLoginFailure?("Wrong Password!")
            default:
                self.onLoginFailure?(error.localizedDescription)
            }
            
        }
    }
//    if email == "test@gmail.com" && password == "1234" {
//        print("HeloooLogin success")
//        onLoginSuccess?()
//    } else {
//        print("Logn nif!/??????")
//        onLoginFailure?("Invalid email or password.")
//    }
    func signupTapped() {
        onNavigateToSignup?()
    }
    func fortesting() {
        let demo = UserRepository()
        let Result = demo.createUser(email: "pradeep@zoho.com", password: "123", profileName: "Pradheep", profileImage: nil, createDate: Date(), dailyReadingGoalMinutes: nil, genre: "")
        switch Result{
        case .failure(let error):
            print(error)
        case .success(let omg):
            print(omg)
        }
        
    }
}
