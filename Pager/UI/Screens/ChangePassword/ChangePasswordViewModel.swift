//
//  ChangePasswordViewModel.swift
//  Pager
//
//  Created by Pradheep G on 12/12/25.
//

import UIKit

@MainActor
class ChangePasswordViewModel {
    let userRepository = UserRepository()
    func changePassword(_ currentPassword: String, _ newPassword: String) {
        guard let user = UserSession.shared.currentUser else {
            return
        }
        Task {
            await userRepository.updatePassword(for: user, currentPassword: currentPassword, newPassword: newPassword)
        }
    }
}
