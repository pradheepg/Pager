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
    func saveUserChange(_ newName: String, _ newEmail: String, _ newGenre: String) -> Result<Void, UserError>{
        guard let user = UserSession.shared.currentUser else {
            return .failure(.saveFailed)
        }
        Task {
            return await userRepository.updateUser(user, email: newEmail, profileName: newName, genre: newGenre)
        }
        return .success(())
    }
    
    func saveUserProfieImage(image: UIImage?) {
        guard let image = image , let imageData = image.pngData(), let user =  UserSession.shared.currentUser else {
            return
        }
        Task {
            let result = await userRepository.updateProfileImage(for: user, imageData: imageData)
            switch result {
            case .success():
                print("Saved")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func removeUserProfileImage() {
        guard let user = UserSession.shared.currentUser else {
            return
        }
        Task {
            let result = await userRepository.removeProflieImage(for: user)
            switch result {
            case .success():
                print("iamge removed")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func saveUserDOB(date: Date) {
        guard let user = UserSession.shared.currentUser else {
            return
        }
        _ = userRepository.updateUserDob(date: date, user)
    }
}
