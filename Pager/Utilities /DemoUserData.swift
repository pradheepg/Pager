//
//  DemoUserData.swift
//  Pager
//
//  Created by Pradheep G on 30/12/25.
//

import Foundation

class DemoUserData {

    let reviewRepo: ReviewRepository
    let collectionRepo: CollectionRepository
    let bookUserRepo: UserBookRecordRepository
    let userRepo: UserRepository
    static let shared = DemoUserData()

    init(reviewRepo: ReviewRepository = ReviewRepository(), collectionRepo: CollectionRepository = CollectionRepository(), bookUserRepo: UserBookRecordRepository = UserBookRecordRepository(), userRepo: UserRepository = UserRepository()) {
        self.reviewRepo = reviewRepo
        self.collectionRepo = collectionRepo
        self.bookUserRepo = bookUserRepo
        self.userRepo = userRepo
    }
    
    func populateSampleData(user: User, allBooks: [Book]) async {
        userRepo.updateUserDob(date: getRandomDate(withinDays: 5000), user)
        await userRepo.updateUser(user,genre: "Novels, Thriller, Kids")
        ReadGoalService.shared.addMinutesToDailyTotal(4.5)
        let shuffledBooks = allBooks.shuffled()
        
        guard shuffledBooks.count >= 30 else {
            print("Error: Need at least 30 books to generate sample data.")
            return
        }
        
        let purchasedBooks = Array(shuffledBooks.prefix(15))
        let otherBooks = Array(shuffledBooks[15..<30])
        let combinedPool = purchasedBooks + otherBooks
        
        
        for (index, book) in purchasedBooks.enumerated() {
            var progress: Double = 0.0
            
            if index < 2 {
                progress = 100.0
            } else if index < 10 {
                progress = Double.random(in: 5...90)
            } else {
                progress = 0.0 // New
            }
            let date = getRandomDate(withinDays: 60)
            bookUserRepo.createRecord(for: book, user: user, date: date, percentage: progress)
            if let bookId = book.bookId {
                userRepo.updateLastOpened(bookId: bookId, user)
            }
            if progress == 100 {
                collectionRepo.addBookToFinishedCollection(book: book, user: user)
            }
        }
        
        
        let booksToReview = purchasedBooks.prefix(10)
        let sampleTitles = ["Great Read", "Loved it", "Pretty good", "Masterpiece", "Not bad"]
        let sampleBodies = ["I really enjoyed the characters.", "Couldn't put it down.", "A bit slow in the middle but great ending.", "Highly recommended for everyone.", "One of the best books I've read this year."]
        
        for (index, book) in booksToReview.enumerated() {
            let rating = Int.random(in: 3...5)
            let date = getRandomDate(withinDays: 60)

            if index < 7 {
                // Full Review (Title + Body)
                let title = sampleTitles.randomElement()
                let body = sampleBodies.randomElement()
                reviewRepo.createReview(for: book, by: user, rating: rating, title: title, text: body, date: date)
            } else {
                // Rating Only (No Title, No Body)
                reviewRepo.createReview(for: book, by: user, rating: rating, title: nil, text: nil, date: date)
            }
        }
        
        // --- STEP 4: COLLECTIONS (3 to 5 Collections) ---
        // Create collections and add randomly from ALL 30 books
        
        let collectionNames = ["Summer Vibes", "Editor's Choice", "Weekend Reads", "Sci-Fi Classics", "Must Read"]
        let numberOfCollections = Int.random(in: 3...5)
        let selectedNames = collectionNames.shuffled().prefix(numberOfCollections)
        
        for name in selectedNames {
            // Create the collection
            let collection = collectionRepo.createCollection(name: name, description: nil, owner: user)
            // Add 4 random books from the combined pool (Owned + Unowned) to this collection
            switch collection {
            case .success(let collection):
                let randomBooks = combinedPool.shuffled().prefix(4)
                
                for book in randomBooks {
                    collectionRepo.addBook(book, to: collection)
                }
            case .failure(let error):
                print(error)
            }

        }
        
        // --- STEP 5: WANT TO READ ---
        // Add some of the unowned books to "Want to Read"
        
        let wantToReadList = otherBooks.prefix(5) // Pick 5 from the unpurchased list
        for book in wantToReadList {
            // Assuming your function takes the book to add
                await collectionRepo.addBookToWantToReadCollection(book: book, user: user)
        }
        
        print("Sample data flow completed successfully.")
    }
    func getRandomDate(withinDays days: Int) -> Date {
        let secondsPerDay: TimeInterval = 60 * 60 * 24
        let maxSeconds = TimeInterval(days) * secondsPerDay
        let randomSeconds = TimeInterval.random(in: 0...maxSeconds)
        return Date().addingTimeInterval(-randomSeconds)
    }
}
