//
//  User+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 26/12/25.
//
//

public import Foundation
public import CoreData


public typealias UserCoreDataPropertiesSet = NSSet

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var createDate: Date?
    @NSManaged public var dailyReadingGoal: Int16
    @NSManaged public var email: String?
    @NSManaged public var favoriteGenres: String?
    @NSManaged public var lastOpenedBookId: UUID?
    @NSManaged public var lastProgressReset: Date?
    @NSManaged public var password: String?
    @NSManaged public var profileImage: Data?
    @NSManaged public var profileName: String?
    @NSManaged public var todayReadingMinutes: Double
    @NSManaged public var userId: UUID?
    @NSManaged public var dob: Date?
    @NSManaged public var collections: NSSet?
    @NSManaged public var owned: NSSet?
    @NSManaged public var reviews: NSSet?

}

// MARK: Generated accessors for collections
extension User {

    @objc(addCollectionsObject:)
    @NSManaged public func addToCollections(_ value: BookCollection)

    @objc(removeCollectionsObject:)
    @NSManaged public func removeFromCollections(_ value: BookCollection)

    @objc(addCollections:)
    @NSManaged public func addToCollections(_ values: NSSet)

    @objc(removeCollections:)
    @NSManaged public func removeFromCollections(_ values: NSSet)

}

// MARK: Generated accessors for owned
extension User {

    @objc(addOwnedObject:)
    @NSManaged public func addToOwned(_ value: UserBookRecord)

    @objc(removeOwnedObject:)
    @NSManaged public func removeFromOwned(_ value: UserBookRecord)

    @objc(addOwned:)
    @NSManaged public func addToOwned(_ values: NSSet)

    @objc(removeOwned:)
    @NSManaged public func removeFromOwned(_ values: NSSet)

}

// MARK: Generated accessors for reviews
extension User {

    @objc(addReviewsObject:)
    @NSManaged public func addToReviews(_ value: Review)

    @objc(removeReviewsObject:)
    @NSManaged public func removeFromReviews(_ value: Review)

    @objc(addReviews:)
    @NSManaged public func addToReviews(_ values: NSSet)

    @objc(removeReviews:)
    @NSManaged public func removeFromReviews(_ values: NSSet)

}

extension User : Identifiable {
    var formattedDOB: String {
        guard let date = self.dob  else {
            return "None"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
}
