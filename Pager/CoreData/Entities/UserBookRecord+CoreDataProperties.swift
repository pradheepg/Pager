//
//  UserBookRecord+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 17/12/25.
//
//

public import Foundation
public import CoreData


public typealias UserBookRecordCoreDataPropertiesSet = NSSet

extension UserBookRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserBookRecord> {
        return NSFetchRequest<UserBookRecord>(entityName: "UserBookRecord")
    }

    @NSManaged public var bookMark: String?
    @NSManaged public var lastOpened: Date?
    @NSManaged public var progressValue: Int64
    @NSManaged public var pruchaseDate: Date?
    @NSManaged public var pruchasePrice: Double
    @NSManaged public var userBookRecordId: UUID?
    @NSManaged public var totalPages: Int64
    @NSManaged public var book: Book?
    @NSManaged public var ownedBy: User?

}

extension UserBookRecord : Identifiable {

}
