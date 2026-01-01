//
//  SignUpViewModel.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import Foundation

class SignUpViewModel {
    var onSignUpSuccess: ((User) -> Void)?
    var onSignUpFailure: ((String) -> Void)?
    
    func signUp(name: String?, email: String?, password: String?, confirmPassword: String?, genre: String?) {
        guard let name = name, !name.isEmpty else {
            onSignUpFailure?("Name cannot be empty.")
            return
        }
        guard let email = email, isValidEmail(email) else {
            onSignUpFailure?("Enter a valid email address.")
            return
        }
        guard let password = password, password.count >= 6 else {
            onSignUpFailure?("Password must be 6+ characters.")
            return
        }
        guard let confirmPassword = confirmPassword, confirmPassword == password else {
            onSignUpFailure?("Passwords do not match.")
            return
        }
//        guard let genre = genre, !genre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            onSignUpFailure?("Please enter your favorite genre.")
//            return
//        }

        // 2. Create user model (replace with repo/network call in real app)
        let result = AuthService.shared.signUp(name: name, email: email, password: password, genre: "")

        switch result {
        case .success(let user):
//            UserSession.shared.saveLoggedInUser(user: user)
            self.onSignUpSuccess?(user)
        case .failure(let error):
            switch error {
            case .emailAlreadyUsed:
                self.onSignUpFailure?("Email Already exists!")
            case .creationFailed:
                self.onSignUpFailure?("CreationFaild!")
            default:
                self.onSignUpFailure?(error.localizedDescription)
            }
            
        }
}
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}

