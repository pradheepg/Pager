//
//  DataLoader.swift
//  Pager
//
//  Created by Pradheep G on 29/12/25.
//

import Foundation
import CoreData
import UIKit

// MARK: - 1. JSON Model
// Matches the structure of your generated books.json
struct ImportBook: Decodable {
    let bookId: String
    let title: String
    let author: String
    let genre: String
    let descriptionText: String
    let language: String
    let coverImageUrl: String
    let contentText: String
    let price: Double
    let averageRating: Double
    let publicationDate: String
}

// MARK: - 2. Loading Logic
class DataLoader {
    
    static let shared = DataLoader()
    private init() {}
    
    /// Loads data from books.json into Core Data if the database is empty.
    func preloadData(context: NSManagedObjectContext) {
        
        // 1. Check if data exists to prevent duplicates
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                print("⚠️ Core Data already has \(count) books. Skipping import.")
                return
            }
        } catch {
            print("Error checking database: \(error)")
            return
        }
        
        // 2. Locate JSON File in Bundle
        guard let url = Bundle.main.url(forResource: "books", withExtension: "json") else {
            print("❌ 'books.json' not found in the App Bundle.")
            return
        }
        
        // 3. Decode and Save
        context.perform { // Ensure we run on the correct Core Data queue
            do {
                let data = try Data(contentsOf: url)
                let importedBooks = try JSONDecoder().decode([ImportBook].self, from: data)
                let dateFormatter = ISO8601DateFormatter()
                
                print("🚀 Starting import of \(importedBooks.count) books...")
                
                for item in importedBooks {
                    let newBook = Book(context: context)
                    
                    // Conversions
                    newBook.bookId = UUID(uuidString: item.bookId) ?? UUID()
                    newBook.publicationDate = dateFormatter.date(from: item.publicationDate) ?? Date()
                    
                    // Direct Assignments
                    newBook.title = item.title
                    newBook.author = item.author
                    newBook.genre = item.genre
                    newBook.descriptionText = item.descriptionText
                    newBook.language = item.language
                    newBook.coverImageUrl = item.coverImageUrl
                    newBook.contentText = item.contentText
                    newBook.price = item.price
                    newBook.averageRating = Float(item.averageRating)
                }
                
                // 4. Save
                try context.save()
                print("✅ Success! Books loaded into Core Data.")
                
            } catch {
                print("❌ Error importing data: \(error)")
            }
        }
    }
}
