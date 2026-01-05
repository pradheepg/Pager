//
//  ReadBookViewModel.swift
//  Pager
//
//  Created by Pradheep G on 16/12/25.
//

import UIKit
import CoreData

class ReadBookViewModel {
    let book: Book
    
    private let themeModeKey: String = "themeModeKey"
    private let isSwipeKey: String = "isSwipeKey"
    private let isSideKey: String = "isSideKey"
    
    private lazy var repostory: CollectionRepository = CollectionRepository()
    
    var themeMode: Int = 2
    var isSwipe: Bool = true
    var isSide: Bool = true
    var progress: Int = 0
    
    let defaults = UserDefaults.standard
    
    init(book: Book) {
        self.book = book
        loadSetting()
    }
    
    //    func loadSetting() {
    //        if let savedSwipe = defaults.object(forKey: isSwipeKey) as? Bool {
    //            isSwipe = savedSwipe
    //        } else {
    //            isSwipe = true
    //        }
    //        if let savedSide = defaults.object(forKey: isSideKey) as? Bool {
    //            isSide = savedSide
    //        } else {
    //            isSide = true
    //        }
    //        isDark = defaults.bool(forKey: isDarkKey)
    //    }
    
    func loadSetting() {
            if let savedSwipe = defaults.object(forKey: isSwipeKey) as? Bool {
                isSwipe = savedSwipe
            } else {
                isSwipe = true
            }
            
            if let savedSide = defaults.object(forKey: isSideKey) as? Bool {
                isSide = savedSide
            } else {
                isSide = true
            }
            
            // Clean Theme Logic: Check if key exists, otherwise default to System (2)
            if defaults.object(forKey: themeModeKey) != nil {
                themeMode = defaults.integer(forKey: themeModeKey)
            } else {
                themeMode = 2
            }
        }
        
        //    func saveSetting() {
        //        defaults.set(isDark, forKey: isDarkKey)
        //        defaults.set(isSwipe, forKey: isSwipeKey)
        //        defaults.set(isSide, forKey: isSideKey)
        //    }
        
        func saveSetting() {
            // CHANGED: Save the Int to the new key
            defaults.set(themeMode, forKey: themeModeKey)
            
            defaults.set(isSwipe, forKey: isSwipeKey)
            defaults.set(isSide, forKey: isSideKey)
        }
        
        func saveProgress(progressValue: Int = 0) {
            guard let user = UserSession.shared.currentUser else {
                return
            }
            user.lastOpenedBookId = book.bookId
            
            let bookRecord = (user.owned?.allObjects as? [UserBookRecord])?.first(where: { $0.book == book })
            bookRecord?.lastOpened = Date()
            bookRecord?.progressValue = Int64(progressValue)
            if let totalPages = bookRecord?.totalPages , (progressValue + 1) >= totalPages  {
                addBookToFinished(book: book)
            }
            
            let context = user.managedObjectContext
            guard let context, context.hasChanges else { return }
            
            do {
                try context.save()
            } catch {
                print("Failed to save progress: \(error)")
            }
            
        }
        
        func addBookToFinished(book: Book) {
            guard let user = UserSession.shared.currentUser else {
                return
            }
            _ = repostory.addBookToFinishedCollection(book: book, user: user)
        }
        
        func loadProgress() -> Int {
            guard let user = UserSession.shared.currentUser else {
                return 0
            }
            let bookRecord = (user.owned?.allObjects as? [UserBookRecord])?.first(where: { $0.book == book })
            return Int(bookRecord?.progressValue ?? 0)
        }
        
        func loadPercentage() -> Double? {
            guard let user = UserSession.shared.currentUser else {
                return 0
            }
            let bookRecord = (user.owned?.allObjects as? [UserBookRecord])?.first(where: { $0.book == book })
            if let percentage = bookRecord?.percentageRead, percentage  > 0 {
                bookRecord?.percentageRead = 0
                try? bookRecord?.managedObjectContext?.save()
                return percentage
            } else {
                return nil
            }
        }
        
        func saveTotalPages(count: Int) {
            guard let user = UserSession.shared.currentUser else {
                return
            }
            let bookRecord = (user.owned?.allObjects as? [UserBookRecord])?.first(where: { $0.book == book })
            bookRecord?.totalPages = Int64(count)
            
            do {
                try bookRecord?.managedObjectContext?.save()
            } catch {
                print("Failed to save total pages: \(error)")
            }
        }
        
    }

