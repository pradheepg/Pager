//
//  BookStoreService.swift
//  Pager
//
//  Created by Pradheep G on 16/12/25.
//

import UIKit

struct BookStoreData {
    var featuredBook: Book?
    var popularBook: [Book]
    var categories: [(String, [Book])]
}

class BookStoreService {
    
    let bookRepository = BookRepository()
    
    
    func fetchBookStoreData() async throws -> BookStoreData {
        
        let featured = await fetchFeaturedBook()
        let popular = await fetchPopularBooks()
        let categories = await fetchCategories()
        
        return BookStoreData(
            featuredBook: featured,
            popularBook: popular,
            categories: categories
        )
    }
    
    private func fetchFeaturedBook() async -> Book? {
        let result = await bookRepository.fetchLatestBooks()
        switch result {
        case .success(let books):
            return books.first
        case .failure(let error):
            print("Could not load: \(error.localizedDescription)")
        }
        return nil
    }
    
    private func fetchPopularBooks() async -> [Book] {
        let result = await bookRepository.fetchTopRatedBooks()
        
        switch result {
        case .success(let books):
            print(books.count)
            return books
            
        case .failure(let error):
            print("Could not load: \(error.localizedDescription)")
        }
        return []
    }
    
    private func fetchCategories() async -> [(String, [Book])] {
        var categoryList: [(String, [Book])] = []
        
        for category in CategoryEnum.allCases {
            
            let result = await bookRepository.fetchBooks(byGenre: category.rawValue)
            
            switch result {
            case .success(let books):
                if !books.isEmpty {
                    categoryList.append((category.rawValue, books))
                }
                
            case .failure(let error):
                print("Could not load \(category.rawValue): \(error.localizedDescription)")
            }
        }
        
        return categoryList
    }
}
