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
            // We use a didSet to automatically notify the VC on change
            didSet {
                // Note: If you were using Combine/ObservableObject, this would be @Published
                onLoadingStateChanged?(isLoading)
            }
        }
        
        // This new closure tells the VC when to update the spinner
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
    func addBookToDefault(book: Book) -> Result<Void, CollectionError> {
        guard let collections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] else {
            return .failure(.notFound)
        }
        guard let defaultCollection = collections.first(where: { $0.isDefault == true }) else {
            return .failure(.notFound)
        }
        return addBook(book, to: defaultCollection)
    }
    func addBook(_ book: Book, to collection: BookCollection) -> Result<Void, CollectionError> {
        return collectionRepository.addBook(book, to: collection)
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
