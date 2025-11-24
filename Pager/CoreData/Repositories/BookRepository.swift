//
//  BookRepository.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import CoreData

enum BookError: Error {
    case notFound
    case saveFailed
    case deleteFailed
    case invalidProgress
}

final class BookRepository {
    
    func createBook(
        title: String,
        author: String,
        genre: String,
        description: String?,
        coverImageUrl: String?,
        contentText: String?
    ) -> Result<Book, BookError> {

        let context = CoreDataManager.shared.context
        let book = Book(context: context)

        book.bookId = UUID()
        book.title = title
        book.author = author
        book.genre = genre
        book.descriptionText = description
        book.coverImageUrl = coverImageUrl
        book.contentText = contentText

        do {
            try CoreDataManager.shared.saveContext()
            return .success(book)
        } catch {
            return .failure(.saveFailed)
        }
    }
    
    func fetchBook(by id: UUID) -> Result<Book, BookError> {
        let context = CoreDataManager.shared.context

        let request: NSFetchRequest<Book> = Book.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            guard let book = try context.fetch(request).first else {
                return .failure(.notFound)
            }
            return .success(book)
        } catch {
            return .failure(.notFound)
        }
    }
    
    func fetchAllBooks() -> Result<[Book], BookError> {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<Book> = Book.fetchRequest()

        do {
            return .success(try context.fetch(request))
        } catch {
            return .failure(.notFound)
        }
    }
    
    func fetchBooks(byGenre genre: String) -> Result<[Book], BookError> {
        let context = CoreDataManager.shared.context

        let request: NSFetchRequest<Book> = Book.fetchRequest()
        request.predicate = NSPredicate(format: "genre == %@", genre)

        do {
            return .success(try context.fetch(request))
        } catch {
            return .failure(.notFound)
        }
    }
    
    func searchBooks(_ query: String) -> Result<[Book], BookError> {
        let context = CoreDataManager.shared.context

        let request: NSFetchRequest<Book> = Book.fetchRequest()
        request.predicate = NSPredicate(
            format: "title CONTAINS[c] %@ OR author CONTAINS[c] %@",
            query, query
        )

        do {
            return .success(try context.fetch(request))
        } catch {
            return .failure(.notFound)
        }
    }
    
    func updateBook(
        _ book: Book,
        title: String?,
        author: String?,
        genre: String?,
        description: String?,
        coverImageUrl: String?,
        contentText: String?
    ) -> Result<Void, BookError> {

        if let title = title { book.title = title }
        if let author = author { book.author = author }
        if let genre = genre { book.genre = genre }
        if let description = description { book.descriptionText = description }
        if let coverURL = coverImageUrl { book.coverImageUrl = coverImageUrl }
        if let fileURL = contentText { book.contentText = fileURL }

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }

}
