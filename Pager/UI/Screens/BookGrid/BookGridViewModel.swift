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
    }
    
    func addToCollection(collection: BookCollection, book: Book) -> Result<Void, CollectionError> {
        let result = repository.addBook(book, to: collection)
        return result
    }
}
