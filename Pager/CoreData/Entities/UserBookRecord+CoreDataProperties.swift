//
//  UserBookRecord+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//
//

public import Foundation
public import CoreData


public typealias UserBookRecordCoreDataPropertiesSet = NSSet

extension UserBookRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserBookRecord> {
        return NSFetchRequest<UserBookRecord>(entityName: "UserBookRecord")
    }

    @NSManaged public var userBookRecordId: UUID?
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var progressValue: Int16
    @NSManaged public var lastOpened: Date?
    @NSManaged public var bookMark: String?
    @NSManaged public var ownedBy: User?
    @NSManaged public var book: Book?

}

extension UserBookRecord : Identifiable {

}
