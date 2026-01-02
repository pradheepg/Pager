//
//  HomeService.swift
//  Pager
//
//  Created by Pradheep G on 11/12/25.
//

import UIKit
import CoreData

struct HomeDashboardData {
    var currentBook: Book?
    var recentBooks: [Book]
    var wantToReadBooks: [Book]
    var categories: [(String, [Book])]
}

class HomeService {
    private let bookRepository: BookRepository
    private let userRepository: UserRepository
    private let userBookRepository: UserBookRecordRepository
    private let collectionRepository: CollectionRepository
    
    init(bookRepository: BookRepository = BookRepository(), userRepository: UserRepository = UserRepository(), userBookRepository: UserBookRecordRepository = UserBookRecordRepository(), collectionRepository: CollectionRepository = CollectionRepository()) {
        self.bookRepository = bookRepository
        self.userRepository = userRepository
        self.userBookRepository = userBookRepository
        self.collectionRepository = collectionRepository
    }  
    
    func fetchHomeDashboardData() async throws -> HomeDashboardData {
        guard let user = UserSession.shared.currentUser else {
            throw UserError.loginRequired
        }
        let currentBookId = user.lastOpenedBookId
        let recentBooks = fetchOwnedBooksSorted(user: user)
        var currentBook: Book? = nil
        if let id = currentBookId {
            currentBook = try? await bookRepository.fetchBook(by: id).get()
        }
        let filteredRecentBooks: [Book]

        if let current = currentBook {
            filteredRecentBooks = recentBooks.filter { $0.objectID != current.objectID }
        } else {
            filteredRecentBooks = recentBooks
        }
        var collectionsBooks: BookCollection?
        switch await collectionRepository.fetchWantToReadCollection(for: user) {
        case .success(let collectionBooks):
            collectionsBooks = collectionBooks
        case .failure(let error):
            print(error.localizedDescription)
        }
        var wantToReadBooks: [Book] = []
        if let collectionsBooks = collectionsBooks, let bookSet = collectionsBooks.books?.array as? [Book]{
            wantToReadBooks = bookSet.reversed()
        }
        return HomeDashboardData(
            currentBook: currentBook,
            recentBooks: filteredRecentBooks,
            wantToReadBooks: wantToReadBooks,
            categories: []
        )
    }
    
    private func fetchOwnedBooksSorted(user: User? = UserSession.shared.currentUser) -> [Book] {
        guard let recordsSet = user?.owned as? Set<UserBookRecord> else {
            return []
        }
        
        let sortedRecords = recordsSet.sorted(by:  { record1, record2 in
            let date1 = record1.lastOpened ?? Date.distantPast
            let date2 = record2.lastOpened ?? Date.distantPast
            return date1 > date2
        } )
        
        let books = sortedRecords.compactMap { $0.book }
        
        return books
    }
}
