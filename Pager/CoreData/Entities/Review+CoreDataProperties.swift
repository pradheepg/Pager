//
//  Review+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//
//

public import Foundation
public import CoreData


public typealias ReviewCoreDataPropertiesSet = NSSet

extension Review {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Review> {
        return NSFetchRequest<Review>(entityName: "Review")
    }

    @NSManaged public var dataCreated: Date?
    @NSManaged public var dateEdited: Date?
    @NSManaged public var rating: Int16
    @NSManaged public var reviewId: UUID?
    @NSManaged public var reviewText: String?
    @NSManaged public var reviewTitle: String?
    @NSManaged public var book: Book?
    @NSManaged public var postedBy: User?

}

extension Review : Identifiable {

}
