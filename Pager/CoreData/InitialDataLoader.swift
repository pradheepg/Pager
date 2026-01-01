////
////  InitialDataLoader.swift
////  Pager
////
////  Created by Pradheep G on 22/11/25.
////
//
//import Foundation
//import CoreData
//
//final class InitialDataLoader {
//
//    static let shared = InitialDataLoader()
//    private init() {}
//
//    private let seedFlagKey = "hasLoadedInitialData"
//
//    func runIfNeeded() {
//        if hasSeededData() { return }
//
//        seedAll()
//        markAsSeeded()
//    }
//
//    private func hasSeededData() -> Bool {
//        UserDefaults.standard.bool(forKey: seedFlagKey)
//    }
//
//    private func markAsSeeded() {
//        UserDefaults.standard.set(true, forKey: seedFlagKey)
//    }
//
//    private func seedAll() {
//        let context = CoreDataManager.shared.context
//
//        let books = loadBooksJSON()
//        let users = loadUsersJSON()
//        let collections = loadCollectionsJSON()
//
//        let insertedUsers = insertUsers(users, into: context)
//        let insertedBooks = insertBooks(books, into: context)
//        insertCollections(collections, users: insertedUsers, into: context)
//
//        saveContext(context)
//
//        print("Initial data loaded successfully.")
//    }
//
//
//    private func loadBooksJSON() -> [BookSeedModel] {
//        loadJSON("books.json")
//    }
//
//    private func loadUsersJSON() -> [UserSeedModel] {
//        loadJSON("users.json")
//    }
//
//    private func loadCollectionsJSON() -> [CollectionSeedModel] {
//        loadJSON("collections.json")
//    }
//
//    // Generic JSON decoder
//    private func loadJSON<T: Decodable>(_ filename: String) -> T {
//        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
//            fatalError("Missing JSON file: \(filename)")
//        }
//
//        do {
//            let data = try Data(contentsOf: url)
//            let decoded = try JSONDecoder().decode(T.self, from: data)
//            return decoded
//        } catch {
//            fatalError("Failed to decode \(filename): \(error)")
//        }
//    }
//
//    // MARK: - Insert Core Data Objects
//
//    @discardableResult
//    private func insertUsers(_ users: [UserSeedModel], into context: NSManagedObjectContext) -> [User] {
//        var inserted: [User] = []
//
//        for u in users {
//            let user = User(context: context)
//            user.userId = u.userId
//            user.email = u.email
//            user.password = u.password
//            user.profileName = u.profileName
//            user.createDate = Date()
//            user.dailyReadingGoalMinutes = Int16(u.dailyGoal)
//            inserted.append(user)
//        }
//
//        return inserted
//    }
//
//    @discardableResult
//    private func insertBooks(_ books: [BookSeedModel], into context: NSManagedObjectContext) -> [Book] {
//        var inserted: [Book] = []
//
//        for b in books {
//            let book = Book(context: context)
//            book.bookId = b.bookId
//            book.title = b.title
//            book.author = b.author
//            book.genre = b.genre
//            book.descriptionText = b.description
//            book.coverImageUrl = b.coverImageUrl
//            book.contentText = b.contentText
//            book.price = b.price
//            book.publicationDate = b.publicationDate
//            inserted.append(book)
//        }
//
//        return inserted
//    }
//
//    private func insertCollections(
//        _ collections: [CollectionSeedModel],
//        users: [User],
//        into context: NSManagedObjectContext
//    ) {
//        for c in collections {
//            let collection = Collection(context: context)
//            collection.collectionId = c.collectionId
//            collection.name = c.name
//            collection.descriptionText = c.description
//            collection.isDefault = c.isDefault
//
//            if let owner = users.first(where: { $0.userId == c.ownerId }) {
//                collection.owner = owner
//            }
//        }
//    }
//
//
//    private func saveContext(_ context: NSManagedObjectContext) {
//        do {
//            try context.save()
//        } catch {
//            fatalError("Failed to save initial data: \(error)")
//        }
//    }
//}
