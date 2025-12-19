//
//  BookStoreViewModel.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import UIKit

class BookStoreViewModel {
    
    var featuredBook: Book?
    var popularBook: [Book] = []
    var categories: [(name: String, books: [Book])] = []
    var isLoading: Bool = false
    var service: BookStoreService = BookStoreService()
    
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private let collectionRepository = CollectionRepository()
    
    func addBook(_ book: Book, to collection: BookCollection) -> Result<Void, CollectionError> {
        return collectionRepository.addBook(book, to: collection)
    }
    func addBookToDefault(book: Book) -> Result<Void, CollectionError> {
        guard let collections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] else {
            return .failure(.notFound)
        }
        guard let defaultCollection = collections.first(where: { $0.isDefault == true }) else {
            return .failure(.notFound)
        }
        return addBook(book, to: defaultCollection)
    }
    
    
    @MainActor
    func loadData() {
        Task {
            do {
                self.isLoading = true
                let payload = try await service.fetchBookStoreData()
                
                self.featuredBook = payload.featuredBook
                self.popularBook = payload.popularBook
                self.categories = payload.categories
//                self.configureSections()
                self.onDataUpdated?()
                
                self.isLoading = false
            } catch {
                print("Error loading home data: \(error)")
                self.onError?(error.localizedDescription)
            }
        }
    }
    
}
