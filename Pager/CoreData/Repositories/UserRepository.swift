//
//  UserRepository.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import Foundation
import CoreData

enum UserError: Error {
    case emailAlreadyExists
    case saveFailed
    case invalidCredentials
    case deleteFailed
    case userNotFound
    case unKnownError(Error)

}

final class UserRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func createUser(
        email: String,
        password: String,
        profileName: String,
        profileImage: Data?,
        createDate: Date,
        dailyReadingGoalMinutes: Int?,
        genre: String
    ) -> Result<User, UserError> {

        if emailExists(email) {
            return .failure(.emailAlreadyExists)
        }
        
        let user = User(context: context)

        let passwordHash = PasswordHashing.hashFuntion(password: password)
        
        user.userId = UUID()
        user.email = email
        user.password = passwordHash
        user.profileName = profileName
        user.profileImage = profileImage
        user.createDate = createDate
        user.favoriteGenres = genre

        if let goal = dailyReadingGoalMinutes {
            user.dailyReadingGoal = Int16(goal)
        }

        do {
            try CoreDataManager.shared.saveContext()
            return .success(user)

        } catch {
            print(error.localizedDescription)
            return .failure(.saveFailed)
        }
    }

    
    private func fetchUser(byEmail email: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }
    
    func emailExists(_ email: String) -> Bool {
        return fetchUser(byEmail: email) != nil
    }

    func validateUser(email: String, password: String) -> Result<User, UserError> {
        guard let user = fetchUser(byEmail: email) else {
            return .failure(.userNotFound)
        }
        
        let hashed = PasswordHashing.hashFuntion(password: password)

        if user.password == hashed {
            return .success(user)
        } else {
            return .failure(.invalidCredentials)
        }
    }
    
    func updateUser(
        _ user: User,
        email: String? = nil,
        profileName: String? = nil,
    ) -> Result<Void, UserError> {

        if let email = email {
            user.email = email
        }

        if let profileName = profileName {
            user.profileName = profileName
        }

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }

    func updatePassword(
        for user: User,
        currentPassword: String,
        newPassword: String
    ) -> Result<Void, UserError> {

        let currentHash = PasswordHashing.hashFuntion(password: currentPassword)

        guard user.password == currentHash else {
            return .failure(.invalidCredentials)
        }

        let newHash = PasswordHashing.hashFuntion(password: newPassword)
        user.password = newHash

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }
    
    func fetchUser(by userId: UUID) -> Result<User, UserError> {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId as CVarArg)
        request.fetchLimit = 1

        do {
            if let user = try context.fetch(request).first {
                return .success(user)
            } else {
                return .failure(.userNotFound)
            }
        } catch {
            return .failure(.unKnownError(error))
        }
    }
    
    func deleteUser(_ user: User) -> Result<Void, UserError> {
        context.delete(user)

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.deleteFailed)
        }
    }

    func updateDailyReadingGoal(for user: User, minutes: Int) -> Result<Void, UserError> {
        user.dailyReadingGoal = Int16(minutes)

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }

    func updateProfileImage(for user: User, imageData: Data) -> Result<Void, UserError> {
        user.profileImage = imageData

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }
}
