//
//  CollectionRepository.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import Foundation
import CoreData

enum CollectionError: Error {
    case notFound
    case alreadyExists
    case saveFailed
    case deleteFailed
    case invalidOwner
    case bookAlreadyInCollection
    case bookNotInCollection
    case cannotDeleteDefaultCollection
}

final class CollectionRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    func createCollection(name: String,
                          description: String?,
                          isDefault: Bool = false,
                          owner: User) -> Result<Collection, CollectionError> {

        if collectionExists(name: name, owner: owner) {
            return .failure(.alreadyExists)
        }

        let collection = Collection(context: context)
        collection.collectionID = UUID()
        collection.name = name
        collection.descriptionText = description
        collection.isDefault = isDefault

        collection.owner = owner

        if isDefault {
            let _ = unsetDefaultCollections(for: owner)
        }

        do {
            try CoreDataManager.shared.saveContext()
            return .success(collection)
        } catch {
            return .failure(.saveFailed)
        }
    }

    func fetchCollection(by id: UUID) -> Result<Collection, CollectionError> {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        request.predicate = NSPredicate(format: "collectionId == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let collection = try context.fetch(request).first else {
                return .failure(.notFound)
            }
            return .success(collection)
        } catch {
            return .failure(.notFound)
        }
    }

    func fetchCollections(for user: User) -> Result<[Collection], CollectionError> {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let collections = try context.fetch(request)
            return .success(collections)
        } catch {
            return .failure(.notFound)
        }
    }

    func fetchDefaultCollection(for user: User) -> Result<Collection?, CollectionError> {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@ AND isDefault == YES", user)
        request.fetchLimit = 1

        do {
            let found = try context.fetch(request).first
            return .success(found)
        } catch {
            return .failure(.notFound)
        }
    }

    func updateCollection(_ collection: Collection,
                          name: String?,
                          description: String?) -> Result<Void, CollectionError> {

        if let name = name {
            if let owner = collection.owner, collectionExists(name: name, owner: owner),
               collection.name != name {
                return .failure(.alreadyExists)
            }
            collection.name = name
        }

        if let desc = description {
            collection.descriptionText = desc
        }

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }

//    not need for now
//    func setDefaultCollection(_ collection: Collection, for user: User) -> Result<Void, CollectionError> {
//        guard userOwnsCollection(collection, user: user) else {
//            return .failure(.invalidOwner)
//        }
//
//        let unsetResult = unsetDefaultCollections(for: user)
//        switch unsetResult {
//        case .failure:
//            return .failure(.saveFailed)
//        case .success:
//            break
//        }
//
//        collection.isDefault = true
//
//        do {
//            try CoreDataManager.shared.saveContext()
//            return .success(())
//        } catch {
//            return .failure(.saveFailed)
//        }
//    }

    func deleteCollection(_ collection: Collection) -> Result<Void, CollectionError> {
        if collection.isDefault == true {
            return .failure(.cannotDeleteDefaultCollection)
        }

        context.delete(collection)

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.deleteFailed)
        }
    }

    func addBook(_ book: Book, to collection: Collection) -> Result<Void, CollectionError> {
        if isBook(book, in: collection) {
            return .failure(.bookAlreadyInCollection)
        }

        // Add to the to-many relationship set safely
        var currentSet = collection.books as? Set<Book> ?? Set<Book>()
        currentSet.insert(book)
        collection.books = currentSet as NSSet

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }

    func removeBook(_ book: Book, from collection: Collection) -> Result<Void, CollectionError> {
        if !isBook(book, in: collection) {
            return .failure(.bookNotInCollection)
        }

        var currentSet = collection.books as? Set<Book> ?? Set<Book>()
        currentSet.remove(book)
        collection.books = currentSet as NSSet

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }

    func isBook(_ book: Book, in collection: Collection) -> Bool {
        guard let set = collection.books as? Set<Book> else { return false }
        return set.contains(book)
    }

    func fetchBooks(in collection: Collection) -> Result<[Book], CollectionError> {
        guard let set = collection.books as? Set<Book> else {
            return .success([])
        }
        let arr = Array(set).sorted { ($0.title ?? "") < ($1.title ?? "") }
        return .success(arr)
    }

    func collectionExists(name: String, owner: User) -> Bool {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@ AND owner == %@", name, owner)
        request.fetchLimit = 1

        return (try? context.fetch(request).first) != nil
    }

    func userOwnsCollection(_ collection: Collection, user: User) -> Bool {
        if collection.owner == user { return true }

        if let colOwner = collection.owner, let colOwnerId = colOwner.userId, let userId = user.userId {
            return colOwnerId == userId
        }

        return false
    }

    private func unsetDefaultCollections(for user: User) -> Result<Void, CollectionError> {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@ AND isDefault == YES", user)

        do {
            let defaults = try context.fetch(request)
            for c in defaults {
                c.isDefault = false
            }
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }
}
