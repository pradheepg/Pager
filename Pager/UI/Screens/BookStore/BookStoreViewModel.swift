//
//  BookStoreViewModel.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import UIKit

class BookStoreViewModel {
    
    var featuredBook: Book?
    var popularBook: [Book] = []
    var categories: [(name: String, books: [Book])] = []
    var isLoading: Bool = false
    var service: BookStoreService = BookStoreService()
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private let collectionRepository = CollectionRepository()
    
    func addBook(_ book: Book, to collection: BookCollection) -> Result<Void, CollectionError> {
        return collectionRepository.addBook(book, to: collection)
    }
    
    func addBookToDefault(book: Book) -> Result<Void, CollectionError> {
        guard let collections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] else {
            return .failure(.notFound)
        }
        guard let defaultCollection = collections.first(where: { $0.isDefault == true }) else {
            return .failure(.notFound)
        }
        return addBook(book, to: defaultCollection)
    }
    
    
    @MainActor
    func loadData() {
        Task {
            do {
                self.isLoading = true
                let payload = try await service.fetchBookStoreData()
                
                self.featuredBook = payload.featuredBook
                self.popularBook = payload.popularBook
                self.categories = payload.categories
//                self.configureSections()
                self.onDataUpdated?()
                
                self.isLoading = false
            } catch {
                print("Error loading home data: \(error)")
                self.onError?(error.localizedDescription)
            }
        }
    }
    
    func isBookInCollection(_ book: Book, collectionName: String) -> Bool {
        guard let user = UserSession.shared.currentUser else { return false }
        
        let wantToReadCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == collectionName
        })
        if let collection = wantToReadCollection, let books = collection.books as? Set<Book> {
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
    
    func addBookToWantToRead(book: Book) -> Result<Void, CollectionError> {
        guard let collections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] else {
            return .failure(.notFound)
        }
        guard let wantToReadCollection = collections.first(
            where: { $0.isDefault && $0.name == DefaultsName.wantToRead }
        ) else {
            return .failure(.notFound)
        }

        return addBook(book, to: wantToReadCollection)
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
}
