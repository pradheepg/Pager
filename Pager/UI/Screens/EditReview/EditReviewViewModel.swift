//
//  EditReviewViewModel.swift
//  Pager
//
//  Created by Pradheep G on 16/12/25.
//

import UIKit

class EditReviewViewModel {
    private let reviewRepository = ReviewRepository()
    let book: Book
    var currentRating: Int = 0
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
    
    
    func getCurrentUserReview() -> Review? {
        guard let currentUser = UserSession.shared.currentUser else { return nil }
        let userReviews = currentUser.reviews?.allObjects as? [Review] ?? []
        return userReviews.first(where: { $0.book == self.book })
    }
    
    func removeReview() -> Result<Void, ReviewError> {
        guard let user = UserSession.shared.currentUser else { return .failure(.notFound) }
        let result: Result<Void,ReviewError>
        if let currentReview = self.getCurrentUserReview() {
            result = reviewRepository.deleteReview(currentReview)
        } else {
            result = .failure(.deleteFailed)
        }
        return result
    }
}
