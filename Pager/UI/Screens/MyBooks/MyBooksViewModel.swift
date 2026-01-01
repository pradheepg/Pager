//
//  MyBooksViewModel.swift
//  Pager
//
//  Created by Pradheep G on 12/12/25.
//

import Foundation
import CoreData

@MainActor
class MyBooksViewModel {
    
    var onDataUpdated: (() -> Void)?
    
    var books: [Book]
    private let collectionRepository: CollectionRepository
    private let userBookRecordRepository: UserBookRecordRepository
    private(set) var currentSortOption: BookSortOption = .lastOpened
    private(set) var currentSortOrder: SortOrder = .ascending
    
    init(books: [Book]) {
        self.books = books
        collectionRepository = CollectionRepository()
        userBookRecordRepository = UserBookRecordRepository()
        applySort()
    }
    
    
    func didSelectSortOption(_ option: BookSortOption) {
        self.currentSortOption = option
        applySort()
    }
    
    func didSelectSortOrder(_ order: SortOrder) {
        self.currentSortOrder = order
        applySort()
    }
    
    func applySort() {
        books.sort { [weak self] (book1: Book, book2: Book) in
            guard let self = self else { return false }

            var isOrderedBefore = false
            
            switch self.currentSortOption {
            case .title:
                let t1 = book1.title ?? ""
                let t2 = book2.title ?? ""
                isOrderedBefore = t1.localizedCaseInsensitiveCompare(t2) == .orderedAscending
            case .author:
                let a1 = book1.author ?? ""
                let a2 = book2.author ?? ""
                isOrderedBefore = a1.localizedCaseInsensitiveCompare(a2) == .orderedAscending
            case .dateAdded:
                let d1 = getDateAdded(for: book1) ?? Date.distantPast
                let d2 = getDateAdded(for: book2) ?? Date.distantPast
                isOrderedBefore = d1 < d2
            case .lastOpened:
                let d1 = getLastOpened(for: book1) ?? Date.distantPast
                let d2 =  getLastOpened(for: book2) ?? Date.distantPast
                isOrderedBefore = d1 < d2
            }
            
            if self.currentSortOrder == .ascending {
                return isOrderedBefore
            } else {
                return !isOrderedBefore
            }
        }
        
        onDataUpdated?()
    }
    
    func addNewCollection(as name: String,description: String? = nil) -> Result<BookCollection, Error> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(UserError.userNotFound)
        }
        switch collectionRepository.createCollection(name: name, description: nil, owner: user) {
        case .success(let bookCollection):
            return .success(bookCollection)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func getDateAdded(for book: Book) -> Date? {
        return getRecord(for: book)?.pruchaseDate

    }
    
    private func getLastOpened(for book: Book) -> Date? {
        return getRecord(for: book)?.lastOpened
    }
    
    func getRecord(for book: Book) -> UserBookRecord? {
        guard let user =  UserSession.shared.currentUser else {
            return nil
        }
        guard let records = user.owned as? Set<UserBookRecord> else {
            return nil
        }
        
        return records.first { $0.book == book }
    }
    func isBookInDefaultCollection(_ book: Book, name: String) -> Bool {
        guard let user = UserSession.shared.currentUser else { return false }
        
        let targetCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == name
        })
        
        if let collection = targetCollection, let books = collection.books as? Set<Book> {
            return books.contains(book)
        }
        return false
    }
    
    
    func deleteFromCollection(collection: BookCollection, book: Book) -> Result<Void, CollectionError> {
        let result = collectionRepository.removeBook(book, from: collection, for: UserSession.shared.currentUser)
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    
    func addToCollection(collection: BookCollection, book: Book) -> Result<Void, CollectionError> {
        let result = collectionRepository.addBook(book, to: collection)
        return result
    }
    
    func addBookToDefault(book: Book) -> Result<Void, CollectionError> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(.notFound)
        }
        
        let wantToReadCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == DefaultsName.wantToRead})
        guard let wantToReadCollection = wantToReadCollection else {
            return .failure(.notFound)
        }
        return addToCollection(collection: wantToReadCollection, book: book)
        
    }
    
    func removeBookFromWantToRead(book: Book) -> Result<Void, CollectionError> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(.notFound)
        }
        
        let wantToReadCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == DefaultsName.wantToRead})
        guard let wantToReadCollection = wantToReadCollection else {
            return .failure(.notFound)
        }
        return deleteFromCollection(collection: wantToReadCollection, book: book)
    }
    
    func isBookInDefaultCollection(_ book: Book) -> Bool {
        guard let user = UserSession.shared.currentUser else { return false }
        
        let wantToReadCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == DefaultsName.wantToRead
        })
        if let collection = wantToReadCollection, let books = collection.books as? Set<Book> {
            return books.contains(book)
        }
        
        return false
    }
    func toggleDefaultCollection(book: Book, collectionName: String) -> Result<Void, CollectionError> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(.notFound)
        }
        let exists = isBookInDefaultCollection(book, name: collectionName)
        
        guard let collection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == collectionName
        }) else {
            return .failure(.noMatches)
        }
        print(exists)
        if exists {
            return deleteFromCollection(collection: collection, book: book)
        } else {
            return addToCollection(collection: collection, book: book)
        }
    }
    
    func unpurchaseBook(_ book: Book) -> Result<Void, UserBookRecordError> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(.notFound)
        }
//        if user.lastOpenedBookId == book.bookId {
//            user.lastOpenedBookId = nil
//            try? user.managedObjectContext?.save()
//        }
        removeBookFromLastOpened(book: book)
        removeBookFromFinishedIfPresent(book: book)
        return userBookRecordRepository.deleteRecord(book: book, user: user)
    }
    func removeBookFromFinishedIfPresent(book: Book) {
        guard let user = UserSession.shared.currentUser else { return }
        
        let finishedCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == "Finished"
        })

        if let collection = finishedCollection,
           let books = collection.books as? Set<Book>,
           books.contains(book) {
            
            _ = deleteFromCollection(collection: collection, book: book)
            
            print("Called deleteFromCollection for Finished list.")
        }
    }
    
    func removeBookFromLastOpened(book: Book) {
        guard let user = UserSession.shared.currentUser else {
            return
        }

        if user.lastOpenedBookId == book.bookId {
            
            if let ownedBooks = user.owned?.allObjects as? [UserBookRecord] {
                
                let nextBook = ownedBooks
                    .filter { $0.book?.bookId != book.bookId }
                    .sorted(by: {
                        ($0.lastOpened ?? $0.pruchaseDate ?? .distantPast) >
                        ($1.lastOpened ?? $1.pruchaseDate ?? .distantPast)
                    })
                    .first
                
                user.lastOpenedBookId = nextBook?.userBookRecordId
            }
        }
    }
}
