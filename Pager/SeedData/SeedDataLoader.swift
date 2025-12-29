//
//  SeedDataLoader.swift
//  Pager
//
//  Created by Pradheep G on 02/12/25.
//

import Foundation
import CoreData
import UIKit

struct SeedData: Decodable {
    let users: [UserDTO]
    let books: [BookDTO]
    let collections: [CollectionDTO]
    let reviews: [ReviewDTO]
    let userBookRecords: [UserBookRecordDTO]
}

struct UserDTO: Decodable {
    let userId: String
    let profileName: String
    let email: String
    let password: String
    let createDate: Date
    let dailyReadingGoal: Int16
    let todayReadingMinutes: Int16
    let favoriteGenres: String?
    let profileImageName: String? // JSON has filename, DB wants Data
}

struct BookDTO: Decodable {
    let bookId: String
    let title: String
    let author: String
    let genre: String
    let language: String
    let descriptionText: String?
    let contentText: String?
    let coverImageUrl: String?
    let publicationDate: Date
    let price: Double
    let averageRating: Float
}

struct CollectionDTO: Decodable {
    let collectionID: String
    let name: String
    let descriptionText: String?
    let isDefault: Bool
    let ownerId: String         // Foreign Key
    let bookIds: [String]       // Many-to-Many Foreign Keys
}

struct ReviewDTO: Decodable {
    let reviewId: String
    let rating: Int16
    let reviewTitle: String?
    let reviewText: String?
    let dateCreated: Date
    let bookId: String          // Foreign Key
    let postedByUserId: String  // Foreign Key
}

struct UserBookRecordDTO: Decodable {
    let userBookRecordId: String
    let progressValue: Int16
    let bookMark: String?
    let lastOpened: Date?
    let purchaseDate: Date    // Timestamp in JSON
    let purchasePrice: Double
    let bookId: String          // Foreign Key
    let ownedByUserId: String   // Foreign Key
}

// MARK: - 2. The Importer Class

class DataLoadder {
    
    static let shared = DataLoadder()
    private init() {}
    
    func loadSeedData(context: NSManagedObjectContext) {
        // 1. Locate the JSON File
        guard let url = Bundle.main.url(forResource: "seed_data", withExtension: "json") else {
            print("❌ Seed data file not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            // 2. Setup Decoder with ISO 8601 Date Strategy
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let seedData = try decoder.decode(SeedData.self, from: data)
            
            print("📂 JSON Decoded. Starting Core Data Import...")
            
            // 3. Performance Optimization: Lookup Maps
            // We store created objects here so we can link them instantly later.
            var userMap: [String: User] = [:]
            var bookMap: [String: Book] = [:]
            
            // --- STEP A: Create Users ---
            for dto in seedData.users {
                let user = User(context: context)
                user.userId = UUID(uuidString: dto.userId)
                user.profileName = dto.profileName
                user.email = dto.email
                user.password = dto.password
                user.createDate = dto.createDate
                user.dailyReadingGoal = dto.dailyReadingGoal
//                user.todayReadingMinutes = dto.todayReadingMinutes
                user.favoriteGenres = dto.favoriteGenres
                
                // Convert Image Name to Binary Data
                if let imgName = dto.profileImageName, let image = UIImage(named: imgName) {
                    user.profileImage = image.jpegData(compressionQuality: 0.8)
                }
                
                userMap[dto.userId] = user
            }
            
            // --- STEP B: Create Books ---
            for dto in seedData.books {
                let book = Book(context: context)
                book.bookId = UUID(uuidString: dto.bookId)
                book.title = dto.title
                book.author = dto.author
                book.genre = dto.genre
                book.language = dto.language
                book.descriptionText = dto.descriptionText
                book.contentText = dto.contentText
                book.coverImageUrl = dto.coverImageUrl
                book.publicationDate = dto.publicationDate
                book.price = dto.price
                book.averageRating = dto.averageRating
                
                bookMap[dto.bookId] = book
            }
            
            // --- STEP C: Create Collections (Links to User and Books) ---
            for dto in seedData.collections {
                let collection = BookCollection(context: context)
                collection.collectionID = UUID(uuidString: dto.collectionID)
                collection.name = dto.name
                collection.descriptionText = dto.descriptionText
                collection.isDefault = dto.isDefault
                
                // Link Owner
                if let owner = userMap[dto.ownerId] {
                    collection.owner = owner
                }
                
                // Link Books
                let booksForCollection = dto.bookIds.compactMap { bookMap[$0] }
                collection.addToBooks(NSSet(array: booksForCollection))
            }
            
            // --- STEP D: Create Reviews (Links to User and Book) ---
            for dto in seedData.reviews {
                let review = Review(context: context)
                review.reviewId = UUID(uuidString: dto.reviewId)
                review.rating = dto.rating
                review.reviewTitle = dto.reviewTitle
                review.reviewText = dto.reviewText
                review.dateCreated = dto.dateCreated
                
                // Link User
                if let user = userMap[dto.postedByUserId] {
                    review.postedBy = user
                }
                
                // Link Book
                if let book = bookMap[dto.bookId] {
                    review.book = book
                }
            }
            
            // --- STEP E: Create UserBookRecords (Links to User and Book) ---
            for dto in seedData.userBookRecords {
                let record = UserBookRecord(context: context)
                record.userBookRecordId = UUID(uuidString: dto.userBookRecordId)
                record.progressValue = Int64(dto.progressValue)
                record.bookMark = dto.bookMark
                record.lastOpened = dto.lastOpened
                
                // Handle Double Timestamp -> Date? if your Core Data uses Date,
                // OR map to Double if your schema used Double (based on XML it was Double)
                record.pruchaseDate = dto.purchaseDate // Maps to the Double in your XML
                record.pruchasePrice = dto.purchasePrice
                
                if let user = userMap[dto.ownedByUserId] {
                    record.ownedBy = user
                }
                
                if let book = bookMap[dto.bookId] {
                    record.book = book
                }
            }
            
            // 4. Save Context
            if context.hasChanges {
                try context.save()
                print("✅ IMPORT SUCCESS: Database populated successfully.")
            } else {
                print("⚠️ No changes to save.")
            }
            
        } catch {
            print("❌ IMPORT ERROR: \(error)")
        }
    }
}
