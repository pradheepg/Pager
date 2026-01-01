////
////  OneTimeLoader.swift
////  Pager
////
////  Created by Pradheep G on 30/12/25.
////
//
//import SwiftUI
//import CoreData
//
//// MARK: - 1. Export Models (Matches your JSON output)
//struct ExportUser: Codable {
//    let userId: String
//    let profileName: String
//    let email: String
//    let password: String // Storing dummy password
//    let createdDate: String
//    let dailyReadingGoal: Int
//}
//
//struct ExportReview: Codable {
//    let reviewId: String
//    let bookId: String
//    let userId: String // To link to User
//    let rating: Int
//    let reviewTitle: String?
//    let reviewText: String?
//    let dateCreated: String
//}
//
//class UserReviewGenerator {
//    var statusMessage = "Ready to generate..."
//    var isProcessing = false
//    
//    // MARK: - CONFIGURATION
//    let targetUserCount = 50       // Total users to create
//    let minReviewsPerBook = 3      // Minimum reviews per book
//    
//    // MARK: - Dummy Data Source
//    let firstNames = ["Aarav", "Vihaan", "Aditya", "Sai", "Arjun", "Reyansh", "Ishaan", "Krishna", "Rohan", "Vivaan", "Ananya", "Diya", "Saanvi", "Aadhya", "Kiara", "Pari", "Mira", "Riya", "Kavya", "Nisha"]
//    let lastNames = ["Patel", "Sharma", "Gupta", "Kumar", "Singh", "Reddy", "Nair", "Iyer", "Verma", "Mehta", "Malhotra", "Joshi", "Shah", "Chopra", "Desai"]
//    let domains = ["gmail.com", "yahoo.in", "outlook.com", "proton.me", "icloud.com"]
//    
//    // Review Templates (Rating, Title, Body)
//    let reviewTemplates: [(Int, String, String)] = [
//        (5, "Masterpiece", "Absolutely loved this! A masterpiece of storytelling."),
//        (4, "Great read", "The ending was a bit rushed, but overall fantastic."),
//        (5, "Highly Recommend", "One of the best books I've read this year."),
//        (3, "It was okay", "Good concepts but slow pacing."),
//        (5, "Life changing", "I couldn't put it down. Changed my perspective."),
//        (4, "Solid", "Very well written. The characters felt so real."),
//        (2, "Not for me", "Found it a bit difficult to get into."),
//        (1, "Disappointed", "Didn't live up to the hype."),
//        (3, "Average", "A decent one-time read."),
//        (4, "Captivating", "Kept me hooked till the last page.")
//    ]
//    
//    // MARK: - Main Function
//    func generateData(context: NSManagedObjectContext) async {
//        await MainActor.run { isProcessing = true; statusMessage = "Fetching Books..." }
//        
//        // 1. Fetch Existing Book IDs from Core Data
//        var allBookIds: [String] = []
//        await context.perform {
//            let request: NSFetchRequest<Book> = Book.fetchRequest() // Assuming your entity is 'Book'
//            if let books = try? context.fetch(request) {
//                // Safely extract UUID strings
//                allBookIds = books.compactMap { $0.bookId?.uuidString }
//            }
//        }
//        
//        if allBookIds.isEmpty {
//            await MainActor.run { statusMessage = "❌ No books found! Run Book Import first."; isProcessing = false }
//            return
//        }
//        
//        // 2. Generate Users
//        await MainActor.run { statusMessage = "Creating \(targetUserCount) Users..." }
//        var users: [ExportUser] = []
//        
//        for _ in 0..<targetUserCount {
//            users.append(createRandomUser())
//        }
//        
//        // 3. Generate Reviews
//        await MainActor.run { statusMessage = "Generating Reviews for \(allBookIds.count) books..." }
//        var reviews: [ExportReview] = []
//        
//        for bookId in allBookIds {
//            // Determine how many reviews this book gets (Random between min and min+3)
//            let count = Int.random(in: minReviewsPerBook...(minReviewsPerBook + 3))
//            
//            // Pick random unique users for this book
//            let shuffledUsers = users.shuffled().prefix(count)
//            
//            for user in shuffledUsers {
//                reviews.append(createReview(bookId: bookId, userId: user.userId))
//            }
//        }
//        
//        // 4. Save to JSON Files
//        saveToJSON(users: users, reviews: reviews)
//    }
//    
//    // MARK: - Logic Helpers
//    
//    func createRandomUser() -> ExportUser {
//        let first = firstNames.randomElement()!
//        let last = lastNames.randomElement()!
//        let domain = domains.randomElement()!
//        let randomNum = Int.random(in: 10...999)
//        
//        // Realistic Email: vihaan.gupta.99@gmail.com
//        let email = "\(first.lowercased()).\(last.lowercased()).\(randomNum)@\(domain)"
//        
//        return ExportUser(
//            userId: UUID().uuidString,
//            profileName: "\(first) \(last)",
//            email: email,
//            password: UUID().uuidString.prefix(8).lowercased(), // Dummy password
//            createdDate: randomDateString(),
//            dailyReadingGoal: 30
//        )
//    }
//    
//    func createReview(bookId: String, userId: String) -> ExportReview {
//        let isRatingOnly = Bool.random() // 50% chance (or adjust logic)
//        
//        // Logic: 30% chance of being "Rating Only" (Empty title/body)
//        let showText = Int.random(in: 1...10) > 3
//        
//        let template = reviewTemplates.randomElement()!
//        var title: String? = template.1
//        var body: String? = template.2
//        let rating = template.0
//        
//        if !showText {
//            title = ""   // Or nil, depending on your preference
//            body = ""    // Or nil
//        }
//        
//        return ExportReview(
//            reviewId: UUID().uuidString,
//            bookId: bookId,
//            userId: userId,
//            rating: rating,
//            reviewTitle: title,
//            reviewText: body,
//            dateCreated: randomDateString()
//        )
//    }
//    
//    func randomDateString() -> String {
//        // Simple ISO8601-like date
//        let year = 2024
//        let month = String(format: "%02d", Int.random(in: 1...12))
//        let day = String(format: "%02d", Int.random(in: 1...28))
//        return "\(year)-\(month)-\(day)"
//    }
//    
//    func saveToJSON(users: [ExportUser], reviews: [ExportReview]) {
//        let fileManager = FileManager.default
//        guard let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        let exportFolder = docDir.appendingPathComponent("BookExport")
//        
//        do {
//            try fileManager.createDirectory(at: exportFolder, withIntermediateDirectories: true)
//            
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//            
//            let userData = try encoder.encode(users)
//            try userData.write(to: exportFolder.appendingPathComponent("users.json"))
//            
//            let reviewData = try encoder.encode(reviews)
//            try reviewData.write(to: exportFolder.appendingPathComponent("reviews.json"))
//            
//            Task { @MainActor in
//                statusMessage = "✅ DONE!\nSaved to: Documents/BookExport\nUsers: \(users.count)\nReviews: \(reviews.count)"
//                isProcessing = false
//                print("📂 Export Path: \(exportFolder.path)")
//            }
//        } catch {
//            Task { @MainActor in statusMessage = "Error saving: \(error)" }
//        }
//    }
//}
