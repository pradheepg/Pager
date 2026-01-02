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
        book.publicationDate = Date()
        
        do {
            try CoreDataManager.shared.saveContext()
            return .success(book)
        } catch {
            print("THis is the erro r",error)
            print("THis is the context: ",error.localizedDescription)
            return .failure(.saveFailed)
        }
    }
    
    func fetchBook(by id: UUID?) async -> Result<Book, BookError> {
        guard let id = id else {
            return .failure(.notFound)
        }
        let context = CoreDataManager.shared.context
//        try await Thread.sleep(forTimeInterval: 5)
//        try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
 
        do {
            let book = try await context.perform {
                let request: NSFetchRequest<Book> = Book.fetchRequest()
                request.predicate = NSPredicate(format: "bookId == %@", id as CVarArg)
                request.fetchLimit = 1
                
                guard let result = try context.fetch(request).first else {
                    throw BookError.notFound
                }
                return result
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
    
    func fetchBooks(byGenre genre: String) async -> Result<[Book], BookError> {
        let context = CoreDataManager.shared.context

        return await context.perform {
            let request: NSFetchRequest<Book> = Book.fetchRequest()
            request.predicate = NSPredicate(format: "genre == %@", genre)

            do {
                let books = try context.fetch(request)
                return .success(books)
            } catch {
                return .failure(.notFound)
            }
        }
    }
    
    func fetchTopRatedBooks() async -> Result<[Book], BookError> {
        let context = CoreDataManager.shared.context
        
        return await context.perform {
            let request: NSFetchRequest<Book> = Book.fetchRequest()
            
            request.sortDescriptors = [NSSortDescriptor(key: "averageRating", ascending: false)]
            
            request.fetchLimit = 10
            
            do {
                let books = try context.fetch(request)
                return .success(books)
            } catch {
                return .failure(.notFound)
            }
        }
    }

    func fetchLatestBooks(limit: Int = 1) async -> Result<[Book], BookError> {
        let context = CoreDataManager.shared.context
        
        return await context.perform {
            let request: NSFetchRequest<Book> = Book.fetchRequest()
            
            request.sortDescriptors = [NSSortDescriptor(key: "publicationDate", ascending: false)]
            
            request.fetchLimit = limit
            
            do {
                let books = try context.fetch(request)
                return .success(books)
            } catch {
                return .failure(.notFound)
            }
        }
    }
    
    func searchBooks(_ query: String, tokenText: String = "") -> Result<[Book], BookError> {
        let context = CoreDataManager.shared.context

        let request: NSFetchRequest<Book> = Book.fetchRequest()
        if tokenText == "" {
            request.predicate = NSPredicate(
                format: "title CONTAINS[c] %@ OR author CONTAINS[c] %@",
                query, query, tokenText
            )
        } else if query == "" {
            request.predicate = NSPredicate(
                format: "genre == %@", tokenText
            )
        } else {
            request.predicate = NSPredicate(
                format: "(title CONTAINS[c] %@ OR author CONTAINS[c] %@) AND genre == %@",
                query, query, tokenText
            )
        }
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
        if let coverURL = coverImageUrl { book.coverImageUrl = coverURL }
        if let fileURL = contentText { book.contentText = fileURL }

        do {
            try CoreDataManager.shared.saveContext()
            return .success(())
        } catch {
            return .failure(.saveFailed)
        }
    }

}
