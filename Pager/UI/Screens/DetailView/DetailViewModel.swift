//
//  DetailViewModel.swift
//  Pager
//
//  Created by Pradheep G on 26/11/25.
//

import UIKit
import CoreData

class DetailViewModel {
    let book: Book
    private let collectionRepository: CollectionRepository
    private let userBookRecordRepository: UserBookRecordRepository
    private let reviewRepository: ReviewRepository
    var reviews: [Review] = []
    var totalReviews: Int {
        if let reviewSet = self.book.reviews  {
            let allReviews = reviewSet.allObjects as? [Review] ?? []
            return allReviews.count
        } else {
            return 0
        }
    }

    init(book: Book) {
        self.book = book
        self.collectionRepository = CollectionRepository()
        self.userBookRecordRepository = UserBookRecordRepository()
        self.reviewRepository = ReviewRepository()
    }
    
    func addBook(_ book: Book, to collection: BookCollection) -> Result<Void, CollectionError> {
        return collectionRepository.addBook(book, to: collection)
    }
    
    func purchaseBook(_ book: Book) -> Result<Void, UserBookRecordError> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(.notFound)
        }
        return userBookRecordRepository.createRecord(for: book, user: user)
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
    
    func addBookToDefault(book: Book) -> Result<Void, CollectionError> {
        guard let collections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] else {
            return .failure(.notFound)
        }
        guard let defaultCollection = collections.first(where: { $0.isDefault == true }) else {
            return .failure(.notFound)
        }
        return addBook(book, to: defaultCollection)
    }
    
    func loadData() {
        guard let reviewSet = self.book.reviews else {
            self.reviews = []
            return
        }

        let allReviews = reviewSet.allObjects as? [Review] ?? []
        let filteredReviews = allReviews.filter { review in
            let hasTitle = !(review.reviewTitle ?? "").isEmpty
            let hasContent = !(review.reviewText ?? "").isEmpty
            
            return hasTitle || hasContent
        }

        self.reviews = filteredReviews.sorted { (first: Review, second: Review) -> Bool in
            return (first.dateEdited ?? Date.distantPast) > (second.dateEdited ?? Date.distantPast)
        }
    }
    
    func getProgress(for star: Int) -> Float {
            guard let allReviews = book.reviews?.allObjects as? [Review], !allReviews.isEmpty else {
                return 0.0
            }
            let totalCount = Float(allReviews.count)
            
            let starCount = allReviews.filter { $0.rating == Int16(star) }.count
            
            return Float(starCount) / totalCount
        }
    
    func submitReview(rating: Int, title: String? = nil, text: String? = nil) -> Result<Void,ReviewError> {
        guard let user = UserSession.shared.currentUser else { return .failure(.saveFailed) }
        let result: Result<Void,ReviewError>
        if let currentReview = self.getCurrentUserReview() {
            result = reviewRepository.updateReview(currentReview, rating: rating, title: title, text: text)
        } else {
            result = reviewRepository.createReview(for: self.book, by: user, rating: rating, title: title, text: text)
        }
        return result
    }
    
    func getCurrentUserReview() -> Review? {
        guard let currentUser = UserSession.shared.currentUser else { return nil }
        let userReviews = currentUser.reviews?.allObjects as? [Review] ?? []
        return userReviews.first(where: { $0.book == self.book })
    }
    func removeBookFromFinishedIfPresent(book: Book) {
        guard let user = UserSession.shared.currentUser else { return }
        
        let finishedCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == "Finished"
        })

        if let collection = finishedCollection,
           let books = collection.books,
           books.contains(book) {
            
            _ = deleteFromCollection(collection: collection, book: book)
            
            print("Called deleteFromCollection for Finished list.")
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
    
    func isBookInDefaultCollection(_ book: Book, name: String) -> Bool {
        guard let user = UserSession.shared.currentUser else { return false }
        
        let targetCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == name
        })
        
        if let collection = targetCollection, let books = collection.books {
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
            return addBook(book, to: collection)
        }
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
