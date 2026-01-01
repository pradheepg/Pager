//
//  BookCollection+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 17/12/25.
//
//

public import Foundation
public import CoreData


public typealias BookCollectionCoreDataPropertiesSet = NSSet

extension BookCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookCollection> {
        return NSFetchRequest<BookCollection>(entityName: "BookCollection")
    }

    @NSManaged public var collectionID: UUID?
    @NSManaged public var descriptionText: String?
    @NSManaged public var isDefault: Bool
    @NSManaged public var name: String?
    @NSManaged public var books: NSSet?
    @NSManaged public var owner: User?

}

// MARK: Generated accessors for books
extension BookCollection {

    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: Book)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: Book)

    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSSet)

    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSSet)

}

extension BookCollection : Identifiable {

}
