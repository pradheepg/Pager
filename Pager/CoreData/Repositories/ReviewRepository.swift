//
//  ReviewRepository.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import CoreData

enum ReviewError: Error {
    case notFound
    case saveFailed
    case deleteFailed
    case alreadyExists
}

final class ReviewRepository {

    private let context = CoreDataManager.shared.context

    func createReview(
        for book: Book,
        by user: User,
        rating: Int,
        title: String?,
        text: String?
    ) -> Result<Review, ReviewError> {

        let existingReviewResult = userReview(for: book, user: user)
        switch existingReviewResult {
        case .success(_):
            return .failure(.alreadyExists)

        case .failure(_):
            break
        }

        let review = Review(context: context)
        review.reviewId = UUID()
        review.rating = Int16(rating)
        review.reviewTitle = title
        review.reviewText = text
        review.dataCreated = Date()
        review.dateEdited = nil
        review.book = book
        review.postedBy = user

        do {
            try CoreDataManager.shared.saveContext()
            return .success(review)
        } catch {
            return .failure(.saveFailed)
        }
    }

    func updateReview(
        _ review: Review,
        rating: Int?,
        title: String?,
        text: String?
    ) -> Result<Void, ReviewError> {

        if let rating = rating { review.rating = Int16(rating) }
        if let title = title { review.reviewTitle = title }
        if let text = text { review.reviewText = text }

        review.dateEdited = Date()

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }

    func deleteReview(_ review: Review) -> Result<Void, ReviewError> {
        context.delete(review)

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.deleteFailed)
        }
    }

    func fetchReview(by id: UUID) -> Result<Review, ReviewError> {
        let request: NSFetchRequest<Review> = Review.fetchRequest()
        request.predicate = NSPredicate(format: "reviewId == %@", id as CVarArg)

        do {
            let result = try context.fetch(request).first
            return result.map { .success($0) } ?? .failure(.notFound)
        } catch {
            return .failure(.notFound)
        }
    }

    func fetchReviews(for book: Book) -> Result<[Review], ReviewError> {
        let request: NSFetchRequest<Review> = Review.fetchRequest()
        request.predicate = NSPredicate(format: "book == %@", book)

        do {
            return .success(try context.fetch(request))
        } catch {
            return .failure(.notFound)
        }
    }

//    not needed now but may be need later
//    func fetchReviews(by user: User) -> Result<[Review], ReviewError> {
//        let request: NSFetchRequest<Review> = Review.fetchRequest()
//        request.predicate = NSPredicate(format: "postedBy == %@", user)
//
//        do {
//            return .success(try context.fetch(request))
//        } catch {
//            return .failure(.notFound)
//        }
//    }

    func averageRating(for book: Book) -> Double {
        switch fetchReviews(for: book) {
        case .failure:
            return 0
        case .success(let list):
            guard !list.isEmpty else { return 0 }
            let total = list.reduce(0) { $0 + Int($1.rating) }
            return Double(total) / Double(list.count)
        }
    }

    func userReview(for book: Book, user: User) -> Result<Review, ReviewError> {
        let request: NSFetchRequest<Review> = Review.fetchRequest()
        request.predicate = NSPredicate(format: "book == %@ AND postedBy == %@", book, user)

        do {
            let result = try context.fetch(request).first
            return result.map { .success($0) } ?? .failure(.notFound)
        } catch {
            return .failure(.notFound)
        }
    }

    func fetchRecentReviews(limit: Int) -> Result<[Review], ReviewError> {
        let request: NSFetchRequest<Review> = Review.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dataCreated", ascending: false)]
        request.fetchLimit = limit

        do {
            return .success(try context.fetch(request))
        } catch {
            return .failure(.notFound)
        }
    }

// may be need in future
//    func fetchTopReviews(for book: Book, limit: Int) -> Result<[Review], ReviewError> {
//        let request: NSFetchRequest<Review> = Review.fetchRequest()
//        request.predicate = NSPredicate(format: "book == %@", book)
//        request.sortDescriptors = [NSSortDescriptor(key: "rating", ascending: false)]
//        request.fetchLimit = limit
//
//        do {
//            return .success(try context.fetch(request))
//        } catch {
//            return .failure(.notFound)
//        }
//    }
}

