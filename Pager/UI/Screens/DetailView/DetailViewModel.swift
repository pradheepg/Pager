//
//  DetailViewModel.swift
//  Pager
//
//  Created by Pradheep G on 26/11/25.
//

import UIKit
internal import CoreData

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
        if user.lastOpenedBookId == book.bookId {
            user.lastOpenedBookId = nil
            try? user.managedObjectContext?.save()
        }
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
    
}
