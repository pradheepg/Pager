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
}
