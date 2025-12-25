//
//  HomeViewModel.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//
import Foundation

@MainActor
class HomeViewModel {
    

    var currentBook: Book? {
        didSet {
            //onDataUpdated?()
        }
    }
    var recentBooks: [Book] = [] {
        didSet {
            //onDataUpdated?()
        }
    }
    var wantToReadBooks: [Book] = [] {
        didSet {
           // onDataUpdated?()
        }
    }
    
    var categories: [(name: String, books: [Book])] = []
    let collectionRepository: CollectionRepository = CollectionRepository()
    private(set) var displayedSections: [HomeSection] = []


    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private let service: HomeService
    
    var isLoading: Bool = false {
            didSet {
                onLoadingStateChanged?(isLoading)
            }
        }
        
        var onLoadingStateChanged: ((Bool) -> Void)?
    
    init(service: HomeService = HomeService()) {
        self.service = service
    }
    
//    func loadData() {
//        service.fetchHomeDashboardData { [weak self] payload in
//            guard let self = self else { return }
//            
//            self.currentBook = payload.currentBook
//            self.recentBooks = payload.recentBooks
//            self.wantToReadBooks = payload.wantToReadBooks
//            self.categories = payload.categories
//            
//            self.configureSections()
//            
//            self.onDataUpdated?()
//        }
//    }
    
    func loadData() {
        Task {
            
            do {
                self.isLoading = true
                let payload = try await service.fetchHomeDashboardData()
                
                self.currentBook = payload.currentBook
                self.recentBooks = payload.recentBooks
                self.wantToReadBooks = payload.wantToReadBooks
                self.categories = payload.categories
                
                
                self.configureSections()
                self.onDataUpdated?()
                
                self.isLoading = false
            } catch {
                print("Error loading home data: \(error)")
                self.onError?(error.localizedDescription)
            }
            
        }
    }
    
    func updateData() {
        Task {
            
            do {
//                self.isLoading = true
                let payload = try await service.fetchHomeDashboardData()
                try await Task.sleep(nanoseconds: 500000000)
//                self.currentBook = payload.currentBook
//                self.recentBooks = payload.recentBooks
                self.wantToReadBooks = payload.wantToReadBooks
                self.categories = payload.categories
                
                
                self.configureSections()
                self.onDataUpdated?()
                
//                self.isLoading = false
            } catch {
                print("Error loading home data: \(error)")
                self.onError?(error.localizedDescription)
            }
            
        }
    }
    
    func configureSections() {
        var sections: [HomeSection] = [.currently]
        
        if !recentBooks.isEmpty {
            sections.append(.recent)
        }
        
        if !wantToReadBooks.isEmpty {
            sections.append(.wantToRead)
        }
        
        for category in categories {
            if !category.books.isEmpty {
                sections.append(.category(category.name, category.books))
            }
        }
        
        self.displayedSections = sections
    }

    
    func numberOfSections() -> Int {
        return displayedSections.count
    }
    
    func sectionType(at index: Int) -> HomeSection {
        guard index < displayedSections.count else { return .currently }
        return displayedSections[index]
    }
    
    func addBookToWantToRead(book: Book) -> Result<Void, CollectionError> {
        guard let collections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] else {
            return .failure(.notFound)
        }
        guard let wantToReadCollection = collections.first(
            where: { $0.isDefault && $0.name == DefaultsName.wantToRead }
        ) else {
            return .failure(.notFound)
        }

        return addBook(book, to: wantToReadCollection)
    }
    
    func addBook(_ book: Book, to collection: BookCollection) -> Result<Void, CollectionError> {
        return collectionRepository.addBook(book, to: collection)
    }
    
    func isBookInCollection(_ book: Book, collectionName: String) -> Bool {
        guard let user = UserSession.shared.currentUser else { return false }
        
        let wantToReadCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == collectionName
        })
        if let collection = wantToReadCollection, let books = collection.books as? Set<Book> {
            return books.contains(book)
        }
        
        return false
    }
    
    func deleteFromCollection(collection: BookCollection, book: Book) -> Result<Void, CollectionError> {
        let result = collectionRepository.removeBook(book, from: collection, for: UserSession.shared.currentUser)
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func removeBookFromWantToRead(book: Book) -> Result<Void, CollectionError> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(.notFound)
        }
        
        let wantToReadCollection = (user.collections?.allObjects as? [BookCollection])?.first(where: {
            $0.isDefault == true && $0.name == DefaultsName.wantToRead})
        guard let wantToReadCollection = wantToReadCollection else {
            return .failure(.notFound)
        }
        return deleteFromCollection(collection: wantToReadCollection, book: book)
    }
    
}

//remove after bug fix driver
class Test {
    
    @MainActor var view: String? = nil
    
    func updateView() {
        
        Task { @MainActor in
            
            self.view = await fetchData(isDB: false)
            
        }
        
    }
    
    func fetchData(isDB: Bool) async -> String? {
        if isDB {
            await fetchDataFromDB()
        } else {
            await withCheckedContinuation { continuation in
                fetchDataFromAPI { value in
                    continuation.resume(returning: value)
                }
            }
        }
    }
    
    func fetchDataFromDB() async -> String? {
        return await Task.detached {
            return "World"
        }.value
    }

    func fetchDataFromAPI(completion: (String) -> Void) {
        completion("Hello")
    }

}
