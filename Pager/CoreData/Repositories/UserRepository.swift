//
//  UserRepository.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import Foundation
import CoreData
import UIKit

enum UserError: Error {
    case emailAlreadyExists
    case saveFailed
    case invalidCredentials
    case deleteFailed
    case userNotFound
    case noLastOpenedBook
    case loginRequired
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
        user.dailyReadingGoal = 5
        
        if let goal = dailyReadingGoalMinutes {
            user.dailyReadingGoal = Int16(goal)
        }
        let wantToReadCollection = BookCollection(context: context)
        wantToReadCollection.collectionID = UUID()
        wantToReadCollection.name = DefaultsName.wantToRead
        wantToReadCollection.isDefault = true
        wantToReadCollection.owner = user
        
        let finishedCollection = BookCollection(context: context)
        finishedCollection.collectionID = UUID()
        finishedCollection.name = DefaultsName.finiahed
        finishedCollection.isDefault = true
        finishedCollection.owner = user
        
//        let name = user.profileName ?? "?"
//        let firstLetter = String(name.prefix(1)).uppercased()
//        if let avatarImage = UIImage.createImageWithLabel(text: firstLetter) {
//            user.profileImage = avatarImage.pngData()
//        }
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
        genre: String? = nil
    ) async -> Result<Void, UserError> {
        
        guard let context = user.managedObjectContext else {
            return .failure(.saveFailed)
        }
        
        let userID = user.objectID
        
        do {
            try await context.perform {
                guard let safeUser = context.object(with: userID) as? User else {
                    throw UserError.userNotFound
                }
                
                if let email = email {
                    safeUser.email = email
                }
                
                if let profileName = profileName {
                    safeUser.profileName = profileName
                }
                
                if let genre = genre {
                    safeUser.favoriteGenres = genre
                }
                
                if context.hasChanges {
                    try context.save()
                }
            }
            
            return .success(())
            
        } catch {
            return .failure(.saveFailed)
        }
    }
    
    func updatePassword(
        for user: User,
        currentPassword: String,
        newPassword: String
    ) async -> Result<Void, UserError> {
        
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
    
    func updateProfileImage(for user: User, imageData: Data) async -> Result<Void, UserError> {
        guard let context = user.managedObjectContext else {
            return .failure(.saveFailed)
        }
        let userID = user.objectID
        
        do {
            try await context.perform {
                guard let safeUser = context.object(with: userID) as? User else {
                    throw UserError.userNotFound
                }
                
                safeUser.profileImage = imageData
                try context.save()
            }
            
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }
    
    func removeProflieImage(for user: User) async -> Result<Void, UserError> {
        guard let context = user.managedObjectContext else {
            return .failure(.saveFailed)
        }
        let userID = user.objectID
        
        do {
            try await context.perform {
                guard let safeUser = context.object(with: userID) as? User else {
                    throw UserError.userNotFound
                }
                
                safeUser.profileImage = nil
                try context.save()
            }
            
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }
    
    func getCurrentBookUUID(_ user: User) -> Result<UUID, UserError> {
        guard let bookId = user.lastOpenedBookId else {
            return .failure(.noLastOpenedBook)
        }
        
        return .success(bookId)
    }
    
    func updateUserDob(date: Date, _ user: User) -> Result<Void, UserError> {
        
        user.dob = date
        
        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }
    
    func updateLastOpened(bookId: UUID, _ user: User) -> Result<Void, UserError> {
        
        user.lastOpenedBookId = bookId
        
        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }
}
