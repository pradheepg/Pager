//
//  BookGridViewModel.swift
//  Pager
//
//  Created by Pradheep G on 12/12/25.
//
import UIKit

class BookGridViewModel {
    let categoryTitle: String
    var books: [Book] = []
    var resultBooks: [Book] = []
    let repository: CollectionRepository
    var currentCollection: BookCollection?
    
    init(categoryTitle: String, books: [Book], currentCollection: BookCollection?, repository: CollectionRepository = CollectionRepository()) {
        self.categoryTitle = categoryTitle
        self.books = books
        self.repository = repository
        
        self.currentCollection = currentCollection
        
    }
    
    func checkForWantToRead() {
        if currentCollection == nil && categoryTitle == DefaultsName.wantToRead {
            currentCollection = fetchWantToReadCollection()
        }
    }
    
    func deleteFromCollection(collection: BookCollection, book: Book) -> Result<Void, CollectionError> {
        let result = repository.removeBook(book, from: collection, for: UserSession.shared.currentUser)
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getUpdatedBookList() {
        guard let currentCollection = currentCollection else {
            return
        }
        books = currentCollection.books?.array as? [Book] ?? []
        resultBooks = books
    }
    
    func addToCollection(collection: BookCollection, book: Book) -> Result<Void, CollectionError> {
        let result = repository.addBook(book, to: collection)
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
    
    func removeBookFromDefault(book: Book) -> Result<Void, CollectionError> {
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
        
        let wantToReadCollection = fetchWantToReadCollection()
//        let wantToReadCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
//            $0.isDefault == true && $0.name == DefaultsName.wantToRead
//        })
        if let collection = wantToReadCollection, let books = collection.books {
            return books.contains(book)
        }
        
        return false
    }
    
    func fetchWantToReadCollection() -> BookCollection? {
        guard let user = UserSession.shared.currentUser else { return nil }

        return (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == DefaultsName.wantToRead
        })
    }
    
    func searchBook(searchText: String) -> Result<Void, CollectionError> {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            resultBooks = books
            return .success(())
        }
        resultBooks = books.filter { book in
            let titleMatch = book.title?.localizedCaseInsensitiveContains(searchText) ?? false
            let authorMatch = book.author?.localizedCaseInsensitiveContains(searchText) ?? false
            return titleMatch || authorMatch
        }
        if resultBooks.isEmpty {
            return .failure(.noMatches)
        }
        return .success(())
    }
 
    func addNewCollection(as name: String,description: String? = nil) -> Result<BookCollection, Error> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(UserError.userNotFound)
        }
        switch repository.createCollection(name: name, description: nil, owner: user) {
        case .success(let bookCollection):
            return .success(bookCollection)
        case .failure(let error):
            return .failure(error)
        }
    }
}
