//
//  UserBookRecordRepository.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import CoreData
import Foundation

enum UserBookRecordError: Error {
    case notFound
    case creationFailed
    case updateFailed
    case deleteFailed
    case coreDataError(Error)
}

final class UserBookRecordRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    func createRecord(for bookId: UUID, user: User) -> Result<UserBookRecord, UserBookRecordError> {
        let bookRequest: NSFetchRequest<Book> = Book.fetchRequest()
        bookRequest.predicate = NSPredicate(format: "bookId == %@", bookId as CVarArg)

        do {
            guard let book = try context.fetch(bookRequest).first else {
                return .failure(.notFound)
            }

            let record = UserBookRecord(context: context)
            record.userBookRecordId = UUID()
            record.book = book
            record.ownedBy = user
//            record.pruchaseData = Date()
            record.progressValue = 0
            record.lastOpened = Date()

            try context.save()
            return .success(record)

        } catch {
            return .failure(.creationFailed)
        }
    }

    func getRecord(for bookId: UUID, user: User) -> Result<UserBookRecord, UserBookRecordError> {
        let request: NSFetchRequest<UserBookRecord> = UserBookRecord.fetchRequest()
        request.predicate = NSPredicate(
            format: "book.bookId == %@ AND ownedBy == %@",
            bookId as CVarArg,
            user
        )

        do {
            guard let record = try context.fetch(request).first else {
                return .failure(.notFound)
            }
            return .success(record)
        } catch {
            return .failure(.coreDataError(error))
        }
    }
    
// neet to update after the flow design

    func updateLastReadPage(bookId: UUID, user: User, page: Int) -> Result<Void, UserBookRecordError> {
        switch getRecord(for: bookId, user: user) {
        case .failure(let err):
            return .failure(err)

        case .success(let record):
            record.bookMark = "\(page)"
            record.lastOpened = Date()

            do {
                try CoreDataManager.shared.saveContext()
                return .success(())
            } catch {
                return .failure(.updateFailed)
            }
        }
    }

    func updateProgress(bookId: UUID, user: User, progress: Double) -> Result<Void, UserBookRecordError> {

        let clamped = max(0, min(progress, 100))

        switch getRecord(for: bookId, user: user) {
        case .failure(let err):
            return .failure(err)

        case .success(let record):
            record.progressValue = Int16(clamped)
            record.lastOpened = Date()

            do {
                try CoreDataManager.shared.saveContext()
                return .success(())
            } catch {
                return .failure(.updateFailed)
            }
        }
    }


    func updateLastOpened(bookId: UUID, user: User) -> Result<Void, UserBookRecordError> {
        switch getRecord(for: bookId, user: user) {
        case .failure(let err):
            return .failure(err)

        case .success(let record):
            record.lastOpened = Date()
            do {
                try CoreDataManager.shared.saveContext()
                return .success(())
            } catch {
                return .failure(.updateFailed)
            }
        }
    }


    func deleteRecord(bookId: UUID, user: User) -> Result<Void, UserBookRecordError> {
        switch getRecord(for: bookId, user: user) {
        case .failure(let err):
            return .failure(err)

        case .success(let record):
            context.delete(record)
            do {
                try CoreDataManager.shared.saveContext()
                return .success(())
            } catch {
                return .failure(.deleteFailed)
            }
        }
    }

    // need to update after flow

    func resetReading(bookId: UUID, user: User) -> Result<Void, UserBookRecordError> {
        switch getRecord(for: bookId, user: user) {
        case .failure(let err):
            return .failure(err)

        case .success(let record):
            record.progressValue = 0
//            record.bookMark = "0"
            record.lastOpened = Date()

            do {
                try CoreDataManager.shared.saveContext()
                return .success(())
            } catch {
                return .failure(.updateFailed)
            }
        }
    }
}
