//
//  MyBooksViewModel.swift
//  Pager
//
//  Created by Pradheep G on 12/12/25.
//

import Foundation

@MainActor
class MyBooksViewModel {
    
    var onDataUpdated: (() -> Void)?
    
    var books: [Book]
    
    private(set) var currentSortOption: BookSortOption = .lastOpened
    private(set) var currentSortOrder: SortOrder = .ascending
    
    init(books: [Book]) {
        self.books = books
        applySort()
    }
    
    
    func didSelectSortOption(_ option: BookSortOption) {
        self.currentSortOption = option
        applySort()
    }
    
    func didSelectSortOrder(_ order: SortOrder) {
        self.currentSortOrder = order
        applySort()
    }
    
    func applySort() {
        
        books.sort { [weak self] (book1: Book, book2: Book) in
            guard let self = self else { return false }

            var isOrderedBefore = false
            
            switch self.currentSortOption {
            case .title:
                let t1 = book1.title ?? ""
                let t2 = book2.title ?? ""
                isOrderedBefore = t1.localizedCaseInsensitiveCompare(t2) == .orderedAscending
            case .author:
                let a1 = book1.author ?? ""
                let a2 = book2.author ?? ""
                isOrderedBefore = a1.localizedCaseInsensitiveCompare(a2) == .orderedAscending
            case .dateAdded:
                let d1 = getDateAdded(for: book1) ?? Date.distantPast
                let d2 = getDateAdded(for: book1) ?? Date.distantPast
                isOrderedBefore = d1 < d2
            case .lastOpened:
                let d1 = getLastOpened(for: book1) ?? Date.distantPast
                let d2 =  getLastOpened(for: book2) ?? Date.distantPast
                isOrderedBefore = d1 < d2
            }
            
            if self.currentSortOrder == .ascending {
                return isOrderedBefore
            } else {
                return !isOrderedBefore
            }
        }
        
        onDataUpdated?()
    }
    
    private func getDateAdded(for book: Book) -> Date? {
        return getRecord(for: book)?.pruchaseDate

    }
    
    private func getLastOpened(for book: Book) -> Date? {
        return getRecord(for: book)?.lastOpened
    }
    
    func getRecord(for book: Book) -> UserBookRecord? {
        guard let user =  UserSession.shared.currentUser else {
            return nil
        }
        guard let records = user.owned as? Set<UserBookRecord> else {
            return nil
        }
        
        return records.first { $0.book == book }
    }
}
