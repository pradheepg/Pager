//
//  SearchViewModel.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//

import UIKit

class SearchViewModel {
    var myBooks: [Book] = []
    var books: [Book] = []
    
    private let bookRepository = BookRepository()
    private let collectionRepository = CollectionRepository()
    
    func searchBooks(searchText: String, token: [UISearchToken]) -> Result<Bool, BookError> {
        var tokentext: String = ""
        if let category = token.first?.representedObject as? CategoryEnum {
            tokentext = category.rawValue
        }
        
       let result =  bookRepository.searchBooks(searchText, tokenText: tokentext)
        switch result {
        case .success(let books):
            filterMyBooks(books)
//            myBooks = books
//            self.books = books
            print(books.count)
            return .success(books.isEmpty)
        case .failure(let error):
            print(error.localizedDescription)
            return .failure(error)
        }
    }
    
    func filterMyBooks(_ results: [Book]) {
        guard let user = UserSession.shared.currentUser,
              let ownedRecords = user.owned?.allObjects as? [UserBookRecord] else {
            self.books = results
            self.myBooks = []
            return
        }
        
        self.myBooks = results.filter { resultBook in
            return ownedRecords.contains(where: { $0.book == resultBook })
        }
        
        self.books = results.filter { resultBook in
            !self.myBooks.contains(resultBook)
        }
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
        if exists {
            return deleteFromCollection(collection: collection, book: book)
        } else {
            return addBook(book, to: collection)
        }
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
    
    func addBook(_ book: Book, to collection: BookCollection) -> Result<Void, CollectionError> {
        return collectionRepository.addBook(book, to: collection)
    }
}
