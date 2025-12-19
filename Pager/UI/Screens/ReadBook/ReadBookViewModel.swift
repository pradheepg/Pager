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
    
    private let isDarkKey: String = "isDarkKey"
    private let isSwipeKey: String = "isSwipeKey"
    private let isSideKey: String = "isSideKey"

    var isDark: Bool = false
    var isSwipe: Bool = true
    var isSide: Bool = true
    var progress: Int = 0
    
    let defaults = UserDefaults.standard

    init(book: Book) {
        self.book = book
        loadSetting()
    }
    
    func loadSetting() {
        isDark = defaults.bool(forKey: "isDark")
        isSwipe = defaults.bool(forKey: "isSwipe")
        isSide = defaults.bool(forKey: "isSide")
    }
    
    func saveSetting() {
        defaults.set(isDark, forKey: "isDark")
        defaults.set(isSwipe, forKey: "isSwipe")
        defaults.set(isSide, forKey: "isSide")
    }
    
    func saveProgress(progressValue: Int = 0) {
        guard let user = UserSession.shared.currentUser else {
            return
        }
        print("Saving book Progress")
        user.lastOpenedBookId = book.bookId
        
        let bookRecord = (user.owned?.allObjects as? [UserBookRecord])?.first(where: { $0.book == book })
        bookRecord?.lastOpened = Date()
        bookRecord?.progressValue = Int64(progressValue)
        
        let context = user.managedObjectContext
        guard let context, context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("Failed to save progress: \(error)")
        }

    }
    
    func loadProgress() -> Int {
        guard let user = UserSession.shared.currentUser else {
            return 0
        }
        let bookRecord = (user.owned?.allObjects as? [UserBookRecord])?.first(where: { $0.book == book })
        return Int(bookRecord?.progressValue ?? 0)
    }

    func saveTotalPages(count: Int) {
        guard let user = UserSession.shared.currentUser else {
            return
        }
        let bookRecord = (user.owned?.allObjects as? [UserBookRecord])?.first(where: { $0.book == book })
        bookRecord?.totalPages = Int64(count)
        
        do {
            try bookRecord?.managedObjectContext?.save()
            print("Saved total pages: \(count)")
        } catch {
            print("Failed to save total pages: \(error)")
        }
    }
}
