//
//  AddToCollectionViewMode.swift
//  Pager
//
//  Created by Pradheep G on 05/01/26.
//
import UIKit

class AddToCollectionViewModel {
    
    let collectionRepository: CollectionRepository = CollectionRepository()
    
    func isBook(_ book: Book, in collection: BookCollection) -> Bool {
        guard let books = collection.books else { return false }
        return books.contains(book)
    }
    
    func toggleBook(_ book: Book, in collection: BookCollection) -> Result<Void,CollectionError> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(.notFound)
        }
        
            let isPresent = isBook(book, in: collection)
            
            if isPresent {
                return collectionRepository.removeBook(book, from: collection, for: user)
            } else {
                return collectionRepository.addBook(book, to: collection)
            }
            
        }
    
    func createCollection(as name: String,description: String? = nil) -> Result<BookCollection, Error> {
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
