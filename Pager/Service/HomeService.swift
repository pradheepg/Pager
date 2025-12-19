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
    
//    init(repository: BookRepository = BookRepository()) {
//            self.repository = repository
    //        }
    //
//    func fetchHomeDashboardData() async throws -> HomeDashboardData {
//        if let id: UUID = await UserSession.shared.currentUser?.lastOpenedBookId {
//
//            try await Task.detached { [weak self] in
//                guard let self = self else { throw UserError.deleteFailed }
//                var currentBook: Book? = nil
//
//
//                let currentBookTask = await bookRepository.fetchBook(by: id)
//                switch currentBookTask {
//                case .success(let book):
//                    currentBook = book
//                case .failure(let error):
//                    print(error.localizedDescription)
//                }
//                //            async let wantToReadTask = repository.fetchBooks(type: "wantToRead")
//                //            async let scifiTask = repository.fetchBooks(type: "Science Fiction")
//
//                let recentBooks = await fetchOwnedBooksSorted()
//                //        try? await Thread.sleep(forTimeInterval: 5)
//
//
//                return HomeDashboardData(
//                    currentBook: currentBook,
//                    recentBooks: recentBooks,
//                    wantToReadBooks: [],//try await wantToReadTask,
//                    categories: [],//[("Science Fiction", try await scifiTask)]
//                )
//            }.value
//        }
//    }
    
    
// non task.distach method ,for reference
//    func fetchHomeDashboardData() async throws -> HomeDashboardData {
//        
//        async let currentBookId = UserSession.shared.currentUser?.lastOpenedBookId
//        async let recentBooks = fetchOwnedBooksSorted()
//
//        let id = await currentBookId
//        let recent = await recentBooks
//
//        var currentBook: Book? = nil
//        if let id = id {
//            currentBook = try await bookRepository.fetchBook(by: id).get()
//        }
//
//        return HomeDashboardData(
//            currentBook: currentBook,
//            recentBooks: recent,
//            wantToReadBooks: [],
//            categories: []
//        )
//    }

//    
//    func fetchHomeDashboardData() async throws -> HomeDashboardData {
//        let currentBookId = UUID(uuidString:"B0000000-0000-0000-0000-000000001342")//UserSession.shared.currentUser?.lastOpenedBookId
//        print(Thread.current.isMainThread)
//        return try await Task.detached { [weak self] in
//            guard let self = self else { throw UserError.deleteFailed }
//            let user = await UserSession.shared.currentUser!
//            let recentBooks = await self.fetchOwnedBooksSorted()
//            var currentBook: Book? = nil
//            _ = await collectionRepository.fetchDefaultCollection(for: user)
//            print(Thread.current.isMainThread)
//
//            if let id = currentBookId {
//                let result = await self.bookRepository.fetchBook(by: id)
//                switch result {
//                case .success(let book):
//                    currentBook = book
//                case .failure(let error):
//                    throw error
//                }
//            }
//            
//            return HomeDashboardData(
//                currentBook: currentBook,
//                recentBooks: recentBooks,
//                wantToReadBooks: [],
//                categories: []
//            )
//        }.value
//    }
//
//    
    
    func fetchHomeDashboardData() async throws -> HomeDashboardData {
        guard let user = UserSession.shared.currentUser else {
            throw UserError.loginRequired
        } //pr
        let currentBookId = user.lastOpenedBookId // UUID(uuidString:"B0000000-0000-0000-0000-000000001342")
        print(currentBookId)
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
        switch await collectionRepository.fetchDefaultCollection(for: user) {
        case .success(let collectionBooks):
            collectionsBooks = collectionBooks
        case .failure(let error):
            print(error.localizedDescription)
        }
        var wantToReadBooks: [Book] = []
        if let collectionsBooks = collectionsBooks, let bookSet = collectionsBooks.books as? Set<Book> {
            wantToReadBooks = Array(bookSet)
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
            return date1 < date2
        } )
        
        let books = sortedRecords.compactMap { $0.book }
        
        return books
    }
}
