//
//  DataLoader.swift
//  Pager
//
//  Created by Pradheep G on 29/12/25.
//

import Foundation
import CoreData
import UIKit

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

class DataLoader {
    
    static let shared = DataLoader()
    private init() {}
    
    func preloadData(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                print("Core Data already has \(count) books. Skipping import.")
                return
            }
        } catch {
            print("Error checking database: \(error)")
            return
        }
        
        let jsonFiles = ["books1", "books2"]
        
        context.perform {
            let dateFormatter = ISO8601DateFormatter()
            
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Could not find Documents Directory")
                return
            }
            
            for fileName in jsonFiles {
                
                guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                    print("'\(fileName).json' not found in the App Bundle. Skipping.")
                    continue
                }
                
                do {
                    print("Reading \(fileName).json...")
                    let data = try Data(contentsOf: url)
                    let importedBooks = try JSONDecoder().decode([ImportBook].self, from: data)
                    
                    print("Importing \(importedBooks.count) books from \(fileName)...")
                    
                    for item in importedBooks {
                        let newBook = Book(context: context)
                        
                        let uuid = UUID(uuidString: item.bookId) ?? UUID()
                        newBook.bookId = uuid
                        newBook.publicationDate = dateFormatter.date(from: item.publicationDate) ?? Date()
                        
                        newBook.title = item.title
                        newBook.author = item.author
                        newBook.genre = item.genre
                        newBook.descriptionText = item.descriptionText
                        newBook.language = item.language
                        newBook.coverImageUrl = item.coverImageUrl
                        newBook.price = item.price
                        newBook.averageRating = Float(item.averageRating)
                        
                        let textFileName = "\(uuid.uuidString).txt"
                        let fileURL = documentsDirectory.appendingPathComponent(textFileName)
                        
                        if !FileManager.default.fileExists(atPath: fileURL.path) {
                            do {
                                try item.contentText.write(to: fileURL, atomically: true, encoding: .utf8)
                                newBook.contentText = textFileName
                            } catch {
                                print("Failed to save text for book '\(item.title)': \(error)")
                                newBook.contentText = nil
                            }
                        } else {
                             newBook.contentText = textFileName
                        }
                    }
                    
                    if context.hasChanges {
                        try context.save()
                        print("Successfully saved batch from \(fileName).")
                    }
                    
                } catch {
                    print("Error importing data from \(fileName): \(error)")
                }
            }
            
            print("All Import Tasks Completed.")
            DataLoader.shared.generateInitialCommunityData(context: context)

        }
    }
}
struct ImportUser: Decodable {
    let userId: String
    let profileName: String
    let email: String
    let password: String
    let createdDate: String
    let dailyReadingGoal: Int
}

struct ImportReview: Decodable {
    let reviewId: String
    let bookId: String
    let userId: String
    let rating: Int
    let reviewTitle: String?
    let reviewText: String?
    let dateCreated: String
}

struct CommunityRawData {
    static let indianNames = [
        "Aarav Patel", "Vihaan Gupta", "Aditya Kumar", "Sai Reddy", "Arjun Nair",
        "Reyansh Sharma", "Ishaan Verma", "Krishna Iyer", "Rohan Mehta", "Vivaan Malhotra",
        "Ananya Joshi", "Diya Shah", "Saanvi Chopra", "Aadhya Desai", "Kiara Singh",
        "Pari Kaur", "Mira Jain", "Riya Agarwal", "Kavya Saxena", "Nisha Rao"
    ]
    
    static let emailDomains = ["gmail.com", "yahoo.in", "outlook.com", "proton.me", "icloud.com"]
    
    static let reviewTemplates: [(title: String?, body: String?, rating: Int)] = [
        ("Masterpiece", "Absolutely loved this! One of the best books I've read this year.", 5),
        ("Great Read", "Very well written, though the ending felt a bit rushed.", 4),
        ("Solid", "Good concepts and characters, but slow pacing in the middle.", 3),
        (nil, nil, 5),
        (nil, nil, 4),
        ("Not for me", "I found it hard to connect with the protagonist.", 2),
        ("Brilliant", "Life changing. I couldn't put it down.", 5),
        ("Average", "It was okay. Not bad, not great.", 3),
        (nil, nil, 3),
        ("Stunning", "A classic for a reason. Simply beautiful prose.", 5),
        ("Informative", "Learned a lot from this.", 4)
    ]
}

extension DataLoader {
    
    func generateInitialCommunityData(context: NSManagedObjectContext) {
        
        context.performAndWait {
            
            let userFetch: NSFetchRequest<User> = User.fetchRequest()
            if (try? context.count(for: userFetch)) ?? 0 > 0 {
                print("Community data (Users/Reviews) already exists. Skipping generation.")
                return
            }
            
            let bookFetch: NSFetchRequest<Book> = Book.fetchRequest()
            guard let allBooks = try? context.fetch(bookFetch), !allBooks.isEmpty else {
                print("No books found! Cannot generate reviews. Make sure preloadData() runs first.")
                return
            }
            
            print("Generating Community: 20 Users & Reviews for \(allBooks.count) Books...")
            
            var createdUsers: [User] = []
            
            for name in CommunityRawData.indianNames {
                let newUser = User(context: context)
                newUser.userId = UUID()
                newUser.profileName = name
                newUser.password = "password123"
                newUser.createDate = randomPastDate()
                
                let cleanedName = name.lowercased().replacingOccurrences(of: " ", with: ".")
                let randomNum = Int.random(in: 10...99)
                let domain = CommunityRawData.emailDomains.randomElement()!
                newUser.email = "\(cleanedName).\(randomNum)@\(domain)"
                
                newUser.dailyReadingGoal = 30
                newUser.todayReadingMinutes = 0
                
                createdUsers.append(newUser)
            }
            
            var totalReviews = 0
            
            for book in allBooks {
                let numberOfReviews = Int.random(in: 3...6)
                let reviewers = createdUsers.shuffled().prefix(numberOfReviews)
                
                for user in reviewers {
                    let review = Review(context: context)
                    review.reviewId = UUID()
                    review.dateCreated = randomPastDate()
                    review.dateEdited = review.dateCreated
                    
                    let template = CommunityRawData.reviewTemplates.randomElement()!
                    
                    review.rating = Int16(template.rating)
                    review.reviewTitle = template.title ?? ""
                    review.reviewText = template.body ?? ""
                    
                    review.book = book
                    review.postedBy = user
                    book.updateAverageRating()
                    totalReviews += 1
                }
            }
            
            do {
                try context.save()
                print("SUCCESS! Generated \(createdUsers.count) users and \(totalReviews) reviews.")
            } catch {
                print("Error saving community data: \(error)")
            }
        }
    }
    
    private func randomPastDate() -> Date {
        let daysAgo = Int.random(in: 1...365)
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }
}
