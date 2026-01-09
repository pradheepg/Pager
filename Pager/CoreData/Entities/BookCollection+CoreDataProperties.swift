//
//  BookCollection+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 02/01/26.
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
    @NSManaged public var createdAt: Date?
    @NSManaged public var books: NSOrderedSet?
    @NSManaged public var owner: User?

}

// MARK: Generated accessors for books
extension BookCollection {

    @objc(insertObject:inBooksAtIndex:)
    @NSManaged public func insertIntoBooks(_ value: Book, at idx: Int)

    @objc(removeObjectFromBooksAtIndex:)
    @NSManaged public func removeFromBooks(at idx: Int)

    @objc(insertBooks:atIndexes:)
    @NSManaged public func insertIntoBooks(_ values: [Book], at indexes: NSIndexSet)

    @objc(removeBooksAtIndexes:)
    @NSManaged public func removeFromBooks(at indexes: NSIndexSet)

    @objc(replaceObjectInBooksAtIndex:withObject:)
    @NSManaged public func replaceBooks(at idx: Int, with value: Book)

    @objc(replaceBooksAtIndexes:withBooks:)
    @NSManaged public func replaceBooks(at indexes: NSIndexSet, with values: [Book])

    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: Book)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: Book)

    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSOrderedSet)

    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSOrderedSet)

}

extension BookCollection : Identifiable {

}
