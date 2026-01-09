//
//  ReviewViewModel.swift
//  Pager
//
//  Created by Pradheep G on 16/12/25.
//

import UIKit

class ReviewViewModel {
    private let reviewRepository = ReviewRepository()
    var reviews: [Review] = []
    let book: Book
    var totalRating: Int {
        if let reviewSet = self.book.reviews {
            let allReviews = reviewSet.allObjects as? [Review] ?? []
            return allReviews.count
        } else {
            return 0
        }
    }
    
    init(book: Book) {
        self.book = book
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
    
    
    func getProgress(for star: Int) -> Float {
        guard let allReviews = book.reviews?.allObjects as? [Review], !allReviews.isEmpty else {
            return 0.0
        }
        let totalCount = Float(allReviews.count)
        
        let starCount = allReviews.filter { $0.rating == Int16(star) }.count
        
        return Float(starCount) / totalCount
    }

    func getCurrentUserReview() -> Review? {
        guard let currentUser = UserSession.shared.currentUser else { return nil }
        let userReviews = currentUser.reviews?.allObjects as? [Review] ?? []
        return userReviews.first(where: { $0.book == self.book })
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
    
}
