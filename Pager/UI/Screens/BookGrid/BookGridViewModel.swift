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
    let currentCollection: BookCollection?
    
    init(categoryTitle: String, books: [Book],currentCollection: BookCollection?, repository: CollectionRepository = CollectionRepository()) {
        self.categoryTitle = categoryTitle
        self.books = books
        self.repository = repository
        self.currentCollection = currentCollection
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
        books = currentCollection.books?.allObjects as? [Book] ?? []
        resultBooks = books
    }
    
    func addToCollection(collection: BookCollection, book: Book) -> Result<Void, CollectionError> {
        let result = repository.addBook(book, to: collection)
        return result
    }
    
    func addBookToDefault(book: Book) -> Result<Void, CollectionError> {
        guard let collections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] else {
            return .failure(.notFound)
        }
        guard let defaultCollection = collections.first(where: { $0.isDefault == true }) else {
            return .failure(.notFound)
        }
        return addToCollection(collection: defaultCollection, book: book)
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
    
}
