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
    private let themeKey: String = "themeKey"
    private let fontSizeKey: String = "fontSizeKey"
    private let fontKey: String = "fontKey"
    
    private lazy var repostory: CollectionRepository = CollectionRepository()
    
    var themeMode: Int = 2
    var isSwipe: Bool = true
    var isSide: Bool = true
//    var progress: Int = 0
    var theme: ThemeEnum = .light
    var fontSize: Float = 18
    var font: FontEnum = .helvetica
    
    let defaults = UserDefaults.standard
    
//    var currentSystemTheme: UIUserInterfaceStyle? = nil
    // = self.traitCollection.userInterfaceStyle
    
    init(book: Book) {
        self.book = book
    }
    
    func configure( currentSystemTheme: UIUserInterfaceStyle? = nil) {
        loadSetting()
    }
    
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
        if defaults.object(forKey: themeModeKey) != nil {
            themeMode = defaults.integer(forKey: themeModeKey)
        } else {
            themeMode = 2
        }
        if defaults.object(forKey: themeKey) != nil {
            let index = defaults.integer(forKey: themeKey)
            theme = ThemeEnum.from(index: index)
        } else {
            theme = .light
        }
        if defaults.object(forKey: fontSizeKey) != nil {
            fontSize = defaults.float(forKey: fontSizeKey)
        } else {
            fontSize = 18
        }
        if defaults.object(forKey: fontKey) != nil {
            let index = defaults.integer(forKey: fontKey)
            font = FontEnum.from(index: index)
        }
        if theme.index == 4 || theme.index == 3 {
            setTheme(style: .dark)
        } else {
            setTheme(style: .light)
        }
    }
    
    func saveSetting() {
        defaults.set(themeMode, forKey: themeModeKey)
        defaults.set(isSwipe, forKey: isSwipeKey)
        defaults.set(isSide, forKey: isSideKey)
        defaults.set(theme.index, forKey: themeKey)
        defaults.set(fontSize, forKey: fontSizeKey)
        defaults.set(font.index, forKey: fontKey)
        if let currentSystemTheme = GobalProperty.systemTheme {
            setTheme(style: currentSystemTheme)
        }
    }
    
//    func saveProgress(progressValue: Int = 0) {
//        guard let user = UserSession.shared.currentUser else {
//            return
//        }
//        user.lastOpenedBookId = book.bookId
//        
//        let bookRecord = (user.owned?.allObjects as? [UserBookRecord])?.first(where: { $0.book == book })
//        bookRecord?.lastOpened = Date()
//        bookRecord?.progressValue = Int64(progressValue)
//        if let totalPages = bookRecord?.totalPages , (progressValue + 1) >= totalPages  {
//            addBookToFinished(book: book)
//        }
//        
//        let context = user.managedObjectContext
//        guard let context, context.hasChanges else { return }
//        
//        do {
//            try context.save()
//        } catch {
//            print("Failed to save progress: \(error)")
//        }
//        
//    }
    func saveProgress(progressValue: Int) {
            
            guard let user = UserSession.shared.currentUser,
                  let context = user.managedObjectContext else {
                return
            }
            
            user.lastOpenedBookId = book.bookId
            
            let bookRecord: UserBookRecord?
            if let ownedBooks = user.owned as? Set<UserBookRecord> {
                 bookRecord = ownedBooks.first(where: { $0.book == book })
            } else {
                 bookRecord = nil
            }
            
            if let record = bookRecord {
                record.lastOpened = Date()
                record.progressValue = Int64(progressValue)
                
                if record.totalPages > 0 && (Int64(progressValue) + 1) >= record.totalPages {
                    addBookToFinished(book: book)
                }
                
                if context.hasChanges {
                    do {
                        try context.save()
                        print("Saved progress: Page \(progressValue)")
                    } catch {
                        print("Failed to save progress: \(error)")
                    }
                }
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
    
    func setTheme(style: UIUserInterfaceStyle) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = style
        }
    }
    
}

