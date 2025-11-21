//
//  Collection+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//
//

public import Foundation
public import CoreData


public typealias CollectionCoreDataPropertiesSet = NSSet

extension Collection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Collection> {
        return NSFetchRequest<Collection>(entityName: "Collection")
    }

    @NSManaged public var collectionId: UUID?
    @NSManaged public var name: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var isDefault: Bool
    @NSManaged public var owner: User?
    @NSManaged public var books: NSSet?

}

// MARK: Generated accessors for books
extension Collection {

    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: Book)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: Book)

    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSSet)

    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSSet)

}

extension Collection : Identifiable {

}
