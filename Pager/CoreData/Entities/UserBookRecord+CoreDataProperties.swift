//
//  UserBookRecord+CoreDataProperties.swift
//  Pager
//
//  Created by Pradheep G on 03/12/25.
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
    @NSManaged public var progressValue: Int16
    @NSManaged public var pruchaseData: Double
    @NSManaged public var pruchasePrice: Double
    @NSManaged public var userBookRecordId: UUID?
    @NSManaged public var book: Book?
    @NSManaged public var ownedBy: User?

}

extension UserBookRecord : Identifiable {

}
