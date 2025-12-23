//
//  ProfileViewModel.swift
//  Pager
//
//  Created by Pradheep G on 12/12/25.
//

import UIKit

@MainActor
class ProfileViewModel {
    let userRepository = UserRepository()
    func saveUserChange(_ newName: String, _ newEmail: String, _ newGenre: String) {
        guard let user = UserSession.shared.currentUser else {
            return
        }
        Task {
            _ = await userRepository.updateUser(user, email: newEmail, profileName: newName, genre: newGenre)
        }
    }
    
    func saveUserProfieImage(image: UIImage?) {
        guard let image = image , let imageData = image.pngData(), let user =  UserSession.shared.currentUser else {
            return
        }
        Task {
            
            _ = await userRepository.updateProfileImage(for: user, imageData: imageData)
        }
    }
    
    func saveUserDOB(date: Date) {
        guard let user = UserSession.shared.currentUser else {
            return
        }
        _ = userRepository.updateUserDob(date: date, user)
    }
}
