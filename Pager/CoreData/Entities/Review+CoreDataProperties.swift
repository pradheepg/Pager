//
//  Review+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//
//

public import Foundation
public import CoreData


public typealias ReviewCoreDataPropertiesSet = NSSet

extension Review {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Review> {
        return NSFetchRequest<Review>(entityName: "Review")
    }

    @NSManaged public var reviewId: UUID?
    @NSManaged public var rating: Int16
    @NSManaged public var reviewText: String?
    @NSManaged public var dataCreated: Date?
    @NSManaged public var dateEdited: Date?
    @NSManaged public var reviewTitle: String?
    @NSManaged public var postedBy: User?
    @NSManaged public var book: Book?

}

extension Review : Identifiable {

}
