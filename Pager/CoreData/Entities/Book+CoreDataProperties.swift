//
//  Book+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 17/12/25.
//
//

public import Foundation
public import CoreData


public typealias BookCoreDataPropertiesSet = NSSet

extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var author: String?
    @NSManaged public var averageRating: Float
    @NSManaged public var bookId: UUID?
    @NSManaged public var contentText: String?
    @NSManaged public var coverImageUrl: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var genre: String?
    @NSManaged public var language: String?
    @NSManaged public var price: Double
    @NSManaged public var publicationDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var collections: NSSet?
    @NSManaged public var reviews: NSSet?
    @NSManaged public var userRecords: NSSet?

}

// MARK: Generated accessors for collections
extension Book {

    @objc(addCollectionsObject:)
    @NSManaged public func addToCollections(_ value: BookCollection)

    @objc(removeCollectionsObject:)
    @NSManaged public func removeFromCollections(_ value: BookCollection)

    @objc(addCollections:)
    @NSManaged public func addToCollections(_ values: NSSet)

    @objc(removeCollections:)
    @NSManaged public func removeFromCollections(_ values: NSSet)

}

// MARK: Generated accessors for reviews
extension Book {

    @objc(addReviewsObject:)
    @NSManaged public func addToReviews(_ value: Review)

    @objc(removeReviewsObject:)
    @NSManaged public func removeFromReviews(_ value: Review)

    @objc(addReviews:)
    @NSManaged public func addToReviews(_ values: NSSet)

    @objc(removeReviews:)
    @NSManaged public func removeFromReviews(_ values: NSSet)

}

// MARK: Generated accessors for userRecords
extension Book {

    @objc(addUserRecordsObject:)
    @NSManaged public func addToUserRecords(_ value: UserBookRecord)

    @objc(removeUserRecordsObject:)
    @NSManaged public func removeFromUserRecords(_ value: UserBookRecord)

    @objc(addUserRecords:)
    @NSManaged public func addToUserRecords(_ values: NSSet)

    @objc(removeUserRecords:)
    @NSManaged public func removeFromUserRecords(_ values: NSSet)

}

extension Book : Identifiable {
    func updateAverageRating() {
        guard let reviews = self.reviews?.allObjects as? [Review], !reviews.isEmpty else {
            self.averageRating = 0.0
            return
        }
        
        let totalRating = reviews.reduce(0) { $0 + Int($1.rating) }
        
        let rawAverage = Float(totalRating) / Float(reviews.count)
        
        let roundedAverage = (rawAverage * 10).rounded() / 10
        
        self.averageRating = roundedAverage
    }
}
