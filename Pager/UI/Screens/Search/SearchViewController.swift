//
//  SearchViewController.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let collectionView: UICollectionView
    private var books: [Book] = []
    let searchController = UISearchController(searchResultsController: nil)
    private var isSearchIng: Bool = false
    private let emptyStateView: EmptyMyBooksViewController = EmptyMyBooksViewController(message: "No Result Found!", isButtonNeeded: false)
    
    
    init() {
        let layout = SearchViewController.createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setUpEmptyState()
        setUpSearchController()
        setUpCollectionView()
    }
    
    private func setUpEmptyState() {
        view.addSubview(emptyStateView.view)
        emptyStateView.view.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.view.isHidden = true
        
        NSLayoutConstraint.activate([
            emptyStateView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
    }
    
    private func setUpCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = AppColors.background // Assumed constant
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    func setUpSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
//        cell.contentView.backgroundColor = AppColors.secondaryBackground
        cell.configure(with: books[indexPath.item])
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = books[indexPath.item]
        let vc = DetailViewController(book: book)
        present(vc, animated: true, completion: .none)
        print("Tapped book:", book.bookId)
    }
    

    func willPresentSearchController(_ searchController: UISearchController) {
        isSearchIng = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        isSearchIng = false
    }
    
    private static func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        section.interGroupSpacing = 15
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        let temp = BookRepository()
        let result = temp.searchBooks(searchText)
        switch result {
        case .success(let books):
            if books.isEmpty && searchText != "" {
                emptyStateView.view.isHidden = false
                collectionView.isHidden = true
                print("this is the problem")
            } else {
                emptyStateView.view.isHidden = true
                collectionView.isHidden = false
            }
            self.books = books
        case .failure(let error):
            print(error.localizedDescription)
        }
        

        
        // Perform filtering logic (e.g., filter your main books array)
        
        // This is necessary to refresh the cells based on the filtered results
        collectionView.reloadData()
    }
}
