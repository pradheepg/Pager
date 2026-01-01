//
//  LibraryViewModel.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import UIKit

class LibraryViewModel {
    
    var myBooks: [Book] = [] {
        didSet {
            onDataUpdated?()
        }
    }
    
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
        
//    func loadBooks() {
//        guard let records = UserSession.shared.currentUser?.owned?.allObjects as? [UserBookRecord] else {
//            self.myBooks = []
//            return
//        }
//        let extractedBooks = records.compactMap { $0.book }
//        self.myBooks = extractedBooks
//    }
    
    func loadBooks() {
        guard let records = UserSession.shared.currentUser?.owned?.allObjects as? [UserBookRecord] else {
            if !self.myBooks.isEmpty {
                self.myBooks = []
            }
            return
        }

        let newBooks = records.compactMap { $0.book }
                              .sorted { ($0.title ?? "") < ($1.title ?? "") }

        if newBooks != self.myBooks {
            self.myBooks = newBooks
            print("Changes detected: UI Updated")
        } else {
            print("No changes: UI Update skipped")
        }
    }
}
