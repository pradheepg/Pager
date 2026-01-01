//
//  Untitled 2.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import Foundation

final class WelcomeViewModel {

    enum Output {
        case goToLogin
        case goToSignUp
    }

    var onOutput: ((Output) -> Void)?

    func userTappedLogin() {
        onOutput?(.goToLogin)
    }

    func userTappedSignUp() {
        onOutput?(.goToSignUp)
    }
}
