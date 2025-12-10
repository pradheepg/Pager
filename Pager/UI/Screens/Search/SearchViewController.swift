////
////  SearchViewController.swift
////  Pager
////
////  Created by Pradheep G on 25/11/25.
////
//
//import UIKit
//
//class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    private var collectionView: UICollectionView!
//    private var books: [Book] = []
//    let searchController = UISearchController(searchResultsController: nil)
//    private var isSearchIng: Bool = false
//    private let emptyStateView: EmptyMyBooksViewController = EmptyMyBooksViewController(message: "No Result Found!", isButtonNeeded: false)
//    
//    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = AppColors.background
//        setUpEmptyState()
//        setUpSearchController()
//        setUpCollectionView()
//    }
//    
//    private func setUpEmptyState() {
//        view.addSubview(emptyStateView.view)
//        emptyStateView.view.translatesAutoresizingMaskIntoConstraints = false
//        emptyStateView.view.isHidden = true
//        
//        NSLayoutConstraint.activate([
//            emptyStateView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            emptyStateView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            emptyStateView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            emptyStateView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//        
//    }
//    
//    private func setUpCollectionView() {
//        print("this")
//        let layout = self.createCompositionalLayout()
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        view.addSubview(collectionView)
//        print("but not this")
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = AppColors.background // Assumed constant
//        
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        
//        collectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
//        collectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
//        collectionView.register(SimpleTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleTitleHeader.reuseID)
//        
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//    }
//    func setUpSearchController() {
//        navigationItem.searchController = searchController
//        searchController.searchResultsUpdater = self
//        searchController.delegate = self
//        navigationItem.hidesSearchBarWhenScrolling = false
//        definesPresentationContext = true
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if !isSearchIng {
//            return CategoryEnum.allCases.count
//        } else {
//            return books.count
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if !isSearchIng {
//            print("THis is that")
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath) as! CategoryPillCell
//        let item = CategoryEnum.allCases[indexPath.item]
//        cell.configure(title: item.rawValue, systemImageName: "arrow.up.forward")
//        return cell
//        
//        } else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell
//            cell.contentView.layer.cornerRadius = 12
//            cell.contentView.layer.masksToBounds = true
//            //        cell.contentView.backgroundColor = AppColors.secondaryBackground
//            cell.configure(with: books[indexPath.item])
//            return cell
//        }
//    }
//        
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if isSearchIng {
//            let book = books[indexPath.item]
//            let vc = DetailViewController(book: book)
//            present(vc, animated: true, completion: .none)
//            print("Tapped book:", book.bookId)
//        }
//    }
//    
//
//    func willPresentSearchController(_ searchController: UISearchController) {
//        isSearchIng = true
//    }
//    
//    func willDismissSearchController(_ searchController: UISearchController) {
//        isSearchIng = false
//    }
//    
//    private func createCompositionalLayout() -> UICollectionViewLayout {
////        if !isSearchIng {
////            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1)))
////            
////            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .absolute(40)), subitems: [item])
////            
////            let section = NSCollectionLayoutSection(group: group)
////            section.orthogonalScrollingBehavior = .continuous
////            section.interGroupSpacing = 10
////            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
////            
////            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
////            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
////            section.boundarySupplementaryItems = [header]
////            
////            return UICollectionViewCompositionalLayout(section: section)
////            
////        }
//        if !isSearchIng {
//            
//            // 1. The Item (The Pill)
//            // We use .estimated width so the pill grows with its text.
//            // .fractionalHeight(1.0) means it fills the height of its container group.
//            let itemSize = NSCollectionLayoutSize(
//                widthDimension: .estimated(100),
//                heightDimension: .fractionalHeight(1.0)
//            )
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            
//            
//            // 2. The Group (A single horizontal row of pills)
//            // .estimated width allows the group to grow as items are added.
//            // .absolute(40) sets the fixed height for the entire row of pills.
//            let groupSize = NSCollectionLayoutSize(
//                widthDimension: .estimated(100),
//                heightDimension: .absolute(40)
//            )
//            let group = NSCollectionLayoutGroup.horizontal(
//                layoutSize: groupSize,
//                subitems: [item]
//            )
//            
//            // 3. The Section (Holds the group and the header)
//            let section = NSCollectionLayoutSection(group: group)
//            
//            // 🌟 KEY POINT: This makes the section scroll horizontally
//            section.orthogonalScrollingBehavior = .continuous
//            
//            // Add spacing between the pills
//            section.interGroupSpacing = 10
//            
//            // Add padding around the entire section
//            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
//            
//            
//            // 4. The Header ("Trending" Title)
//            // A header that spans the full width and has a fixed height.
//            let headerSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .absolute(50) // Taller height to account for title padding
//            )
//            let header = NSCollectionLayoutBoundarySupplementaryItem(
//                layoutSize: headerSize,
//                elementKind: UICollectionView.elementKindSectionHeader,
//                alignment: .top
//            )
//            // Pin the header to the top of the section
//            header.pinToVisibleBounds = true
//            
//            // Add the header to the section
//            section.boundarySupplementaryItems = [header]
//            
//            // 5. Create and return the final layout
//            return UICollectionViewCompositionalLayout(section: section)
//        } else {
//            let itemSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .fractionalHeight(1.0)
//            )
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            
//            let groupSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .absolute(150)
//            )
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//            
//            let section = NSCollectionLayoutSection(group: group)
//            
//            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//            
//            section.interGroupSpacing = 15
//            
//            return UICollectionViewCompositionalLayout(section: section)
//        }
//    }
//    
//    func updateLayoutForSearchState() {
//        let newLayout = createCompositionalLayout()
//        collectionView.setCollectionViewLayout(newLayout, animated: true) { completed in
//            if completed {
//                self.collectionView.setContentOffset(.zero, animated: true)
//            }
//        }
//    }
//    
//    func updateSearchResults(for searchController: UISearchController) {
//        let searchText = searchController.searchBar.text ?? ""
//        let temp = BookRepository()
//        let result = temp.searchBooks(searchText)
//        switch result {
//        case .success(let books):
//            if books.isEmpty && searchText != "" {
//                emptyStateView.view.isHidden = false
//                collectionView.isHidden = true
//                print("this is the problem")
//            } else {
//                emptyStateView.view.isHidden = true
//                collectionView.isHidden = false
//            }
//            self.books = books
//        case .failure(let error):
//            print(error.localizedDescription)
//        }
//        updateLayoutForSearchState()
//        collectionView.reloadData()
//    }
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        if kind == UICollectionView.elementKindSectionHeader {
//            if !isSearchIng {
//                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SimpleTitleHeader.reuseID, for: indexPath) as! SimpleTitleHeader
//                header.titleLabel.text = "Categories"
//                return header
//            }
//            
//        }
//        return UICollectionReusableView()
//    }
//}
//
//
//class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        let attributes = super.layoutAttributesForElements(in: rect)
//        var leftMargin = sectionInset.left
//        var maxY: CGFloat = -1.0
//        
//        attributes?.forEach { layoutAttribute in
//            if layoutAttribute.frame.origin.y >= maxY {
//                leftMargin = sectionInset.left
//            }
//            layoutAttribute.frame.origin.x = leftMargin
//            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
//            maxY = max(layoutAttribute.frame.maxY, maxY)
//        }
//        return attributes
//    }
//}
//
////
////import UIKit
////
////class SearchViewConttroller: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
////    
////    // MARK: - UI & Data
////    private var collectionView: UICollectionView!
////    private var books: [Book] = []
////    
////    // Keep a single instance of the repo
////    private let bookRepository = BookRepository()
////    
////    let searchController = UISearchController(searchResultsController: nil)
////    
////    // State tracking to prevent unnecessary layout updates
////    private var isSearchActive: Bool = false
////    
////    private let emptyStateView: EmptyMyBooksViewController = EmptyMyBooksViewController(message: "No Result Found!", isButtonNeeded: false)
////    
////    // MARK: - Lifecycle
////    init() {
////        super.init(nibName: nil, bundle: nil)
////    }
////    
////    required init?(coder: NSCoder) { fatalError() }
////    
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        view.backgroundColor = .systemBackground
////        
////        setUpEmptyState()
////        setUpSearchController()
////        setUpCollectionView() // This now sets the initial layout
////    }
////    
////    // MARK: - Setup
////    private func setUpEmptyState() {
////        view.addSubview(emptyStateView.view)
////        addChild(emptyStateView)
////        emptyStateView.didMove(toParent: self)
////        
////        emptyStateView.view.translatesAutoresizingMaskIntoConstraints = false
////        emptyStateView.view.isHidden = true
////        
////        NSLayoutConstraint.activate([
////            emptyStateView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
////            emptyStateView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
////            emptyStateView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
////            emptyStateView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
////        ])
////    }
////    
////    private func setUpCollectionView() {
////        // Start with the Tags Layout (Flow)
////        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout(isSearching: false))
////        collectionView.translatesAutoresizingMaskIntoConstraints = false
////        collectionView.backgroundColor = .systemBackground
////        
////        collectionView.dataSource = self
////        collectionView.delegate = self
////        
////        // Register Cells & Headers
////        collectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
////        collectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
////        collectionView.register(SimpleTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleTitleHeader.reuseID)
////        
////        view.addSubview(collectionView)
////        NSLayoutConstraint.activate([
////            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
////            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
////            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
////            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
////        ])
////    }
////    
////    func setUpSearchController() {
////        navigationItem.searchController = searchController
////        searchController.searchResultsUpdater = self
////        searchController.delegate = self
////        navigationItem.hidesSearchBarWhenScrolling = false
////        definesPresentationContext = true
////    }
////    
////    // MARK: - Search Logic
////    
////    func updateSearchResults(for searchController: UISearchController) {
////        let searchText = searchController.searchBar.text ?? ""
////        let hasText = !searchText.isEmpty
////        
////        // 1. Layout Switching Logic
////        // Only update layout if the state CHANGED (Optimization)
////        if isSearchActive != hasText {
////            isSearchActive = hasText
////            updateLayout(isSearching: isSearchActive)
////        }
////        
////        // 2. Data Logic
////        if hasText {
////            let result = bookRepository.searchBooks(searchText)
////            switch result {
////            case .success(let foundBooks):
////                self.books = foundBooks
////                
////                // Toggle Empty State
////                let shouldShowEmpty = foundBooks.isEmpty
////                emptyStateView.view.isHidden = !shouldShowEmpty
////                collectionView.isHidden = shouldShowEmpty
////                
////            case .failure(let error):
////                print(error.localizedDescription)
////            }
////        } else {
////            // Reset to default state
////            emptyStateView.view.isHidden = true
////            collectionView.isHidden = false
////            self.books = []
////        }
////        
////        collectionView.reloadData()
////    }
////    
////    // MARK: - Layout Logic
////    
////    private func updateLayout(isSearching: Bool) {
////        let newLayout = createLayout(isSearching: isSearching)
////        
////        // Animate the swap between Flow (Tags) and Compositional (List)
////        collectionView.setCollectionViewLayout(newLayout, animated: true) { completed in
////            if completed {
////                self.collectionView.setContentOffset(.zero, animated: true)
////            }
////        }
////    }
////    
////    private func createLayout(isSearching: Bool) -> UICollectionViewLayout {
////        if !isSearching {
////            let layout = LeftAlignedFlowLayout()
////            layout.scrollDirection = .vertical
////            layout.minimumLineSpacing = 10
////            layout.minimumInteritemSpacing = 10
////            layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
////            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
////            layout.headerReferenceSize = CGSize(width: view.frame.width, height: 40)
////            return layout
////            
////        } else {
////            return UICollectionViewCompositionalLayout { sectionIndex, _ in
////                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
////                let item = NSCollectionLayoutItem(layoutSize: itemSize)
////                
////                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120)) // Adjusted height for book row
////                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
////                
////                let section = NSCollectionLayoutSection(group: group)
////                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
////                section.interGroupSpacing = 15
////                return section
////            }
////        }
////    }
////
////    // MARK: - Data Source
////    
////    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        if !isSearchActive {
////            return CategoryEnum.allCases.count
////        } else {
////            return books.count
////        }
////    }
////    
////    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        if !isSearchActive {
////            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath) as! CategoryPillCell
////            let item = CategoryEnum.allCases[indexPath.item]
////            cell.configure(title: item.rawValue, systemImageName: item.systemImageName)
////            return cell
////        } else {
////            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell
////            cell.configure(with: books[indexPath.item])
////            // Note: Don't set corner radius on contentView here if it causes performance issues, do it in the Cell class
////            return cell
////        }
////    }
////    
////    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
////        if kind == UICollectionView.elementKindSectionHeader {
////            // Only show header in Tags mode
////            if !isSearchActive {
////                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SimpleTitleHeader.reuseID, for: indexPath) as! SimpleTitleHeader
////                header.titleLabel.text = "Categories" // or "Top Searches"
////                return header
////            }
////        }
////        return UICollectionReusableView()
////    }
////    
////    // MARK: - Selection
////    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        if isSearchActive {
////            // Navigate to Book Detail
////            let book = books[indexPath.item]
////            let vc = DetailViewController(book: book)
////            // Push is usually better than Present for Search
////            navigationController?.pushViewController(vc, animated: true)
////        } else {
////            // Handle Category Tap (Optional: Fill search bar with category name)
////            let category = CategoryEnum.allCases[indexPath.item]
////            print("Selected Category: \(category.rawValue)")
////            searchController.searchBar.text = category.rawValue
////            // updateSearchResults will fire automatically if you update text
////        }
////    }
////}
////
////import UIKit
////
////class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
////    
////    // MARK: - Properties
////    
////    private var collectionView: UICollectionView!
////    
////    // Data Sources
////    private var books: [Book] = []
////    
////    // Repository (Created once for performance)
////    private let bookRepository = BookRepository()
////    
////    // Search Controller
////    let searchController = UISearchController(searchResultsController: nil)
////    
////    // State Tracking
////    private var isSearchActive: Bool = false
////    
////    // Empty State View
////    private let emptyStateView: EmptyMyBooksViewController = EmptyMyBooksViewController(message: "No Result Found!", isButtonNeeded: false)
////    
////    // MARK: - Lifecycle
////    
////    init() {
////        super.init(nibName: nil, bundle: nil)
////    }
////    
////    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
////    
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        view.backgroundColor = .systemBackground
////        
////        setUpEmptyState()
////        setUpSearchController()
////        setUpCollectionView() // Layout is created here where view bounds are known
////    }
////    
////    // MARK: - Setup UI
////    
////    private func setUpEmptyState() {
////        addChild(emptyStateView)
////        view.addSubview(emptyStateView.view)
////        emptyStateView.didMove(toParent: self)
////        
////        emptyStateView.view.translatesAutoresizingMaskIntoConstraints = false
////        emptyStateView.view.isHidden = true
////        
////        NSLayoutConstraint.activate([
////            emptyStateView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
////            emptyStateView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
////            emptyStateView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
////            emptyStateView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
////        ])
////    }
////    
////    private func setUpCollectionView() {
////        // Initial Layout: "Tags" (Flow Layout)
////        let initialLayout = createLayout(isSearching: false)
////        
////        collectionView = UICollectionView(frame: .zero, collectionViewLayout: initialLayout)
////        collectionView.translatesAutoresizingMaskIntoConstraints = false
////        collectionView.backgroundColor = .systemBackground
////        
////        // Register Cells & Headers
////        collectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
////        collectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
////        collectionView.register(SimpleTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleTitleHeader.reuseID)
////        
////        collectionView.dataSource = self
////        collectionView.delegate = self
////        
////        view.addSubview(collectionView)
////        
////        NSLayoutConstraint.activate([
////            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
////            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
////            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
////            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
////        ])
////    }
////    
////    func setUpSearchController() {
////        navigationItem.searchController = searchController
////        searchController.searchResultsUpdater = self
////        searchController.delegate = self
////        navigationItem.hidesSearchBarWhenScrolling = false
////        definesPresentationContext = true
////        searchController.searchBar.placeholder = "Search books, authors..."
////    }
////    
////    // MARK: - Search Logic
////    
////    func updateSearchResults(for searchController: UISearchController) {
////        let searchText = searchController.searchBar.text ?? ""
////        let hasText = !searchText.isEmpty
////        
////        // 1. Layout Switching Logic (Optimization: Only update if state CHANGED)
////        if isSearchActive != hasText {
////            isSearchActive = hasText
////            updateLayout(isSearching: isSearchActive)
////        }
////        
////        // 2. Data Filtering Logic
////        if hasText {
////            let result = bookRepository.searchBooks(searchText)
////            switch result {
////            case .success(let foundBooks):
////                self.books = foundBooks
////                
////                // Toggle Empty State Visibility
////                let shouldShowEmpty = foundBooks.isEmpty
////                emptyStateView.view.isHidden = !shouldShowEmpty
////                collectionView.isHidden = shouldShowEmpty
////                
////            case .failure(let error):
////                print("Search Error: \(error.localizedDescription)")
////            }
////        } else {
////            // Reset to "Top Searches" / Categories state
////            emptyStateView.view.isHidden = true
////            collectionView.isHidden = false
////            self.books = []
////        }
////        
////        // Reload data to reflect changes
////        collectionView.reloadData()
////    }
////    
////    // MARK: - Layout Logic
////    
////    private func updateLayout(isSearching: Bool) {
////        let newLayout = createLayout(isSearching: isSearching)
////        
////        // Animate the layout change for a smooth transition
////        collectionView.setCollectionViewLayout(newLayout, animated: true) { completed in
////            if completed && isSearching {
////                // Scroll to top when showing search results
////                self.collectionView.setContentOffset(.zero, animated: true)
////            }
////        }
////    }
////    
////    private func createLayout(isSearching: Bool) -> UICollectionViewLayout {
////        if !isSearching {
////            // --- TAGS MODE: Use LeftAlignedFlowLayout ---
////            let layout = LeftAlignedFlowLayout()
////            layout.scrollDirection = .vertical
////            layout.minimumLineSpacing = 10
////            layout.minimumInteritemSpacing = 10
////            layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
////            
////            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
////            
////            // Header Width uses view.bounds.width safely here
////            layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 50)
////            
////            return layout
////            
////        } else {
////            // --- SEARCH RESULTS MODE: Use Compositional Layout ---
////            return UICollectionViewCompositionalLayout { sectionIndex, _ in
////                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
////                let item = NSCollectionLayoutItem(layoutSize: itemSize)
////                
////                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
////                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
////                
////                let section = NSCollectionLayoutSection(group: group)
////                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
////                section.interGroupSpacing = 15
////                return section
////            }
////        }
////    }
////
////    // MARK: - UICollectionViewDataSource
////    
////    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        if !isSearchActive {
////            return CategoryEnum.allCases.count
////        } else {
////            return books.count
////        }
////    }
////    
////    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        if !isSearchActive {
////            // Tag Cell
////            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath) as! CategoryPillCell
////            let item = CategoryEnum.allCases[indexPath.item]
////            cell.configure(title: item.rawValue, systemImageName: item.systemImageName)
////            return cell
////        } else {
////            // Book Result Cell
////            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell
////            cell.configure(with: books[indexPath.item])
////            return cell
////        }
////    }
////    
////    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
////        if kind == UICollectionView.elementKindSectionHeader {
////            // Show Header only in Tags Mode
////            if !isSearchActive {
////                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SimpleTitleHeader.reuseID, for: indexPath) as! SimpleTitleHeader
////                header.titleLabel.text = "Categories" // or "Top Searches"
////                return header
////            }
////        }
////        return UICollectionReusableView()
////    }
////    
////    // MARK: - UICollectionViewDelegate
////    
////    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        if isSearchActive {
////            // Navigate to Book Detail
////            let book = books[indexPath.item]
////            let vc = DetailViewController(book: book)
////            navigationController?.pushViewController(vc, animated: true)
////        } else {
////            // Handle Tag Tap -> Populate Search Bar
////            let category = CategoryEnum.allCases[indexPath.item]
////            print("Selected Category: \(category.rawValue)")
////            searchController.searchBar.text = category.rawValue
////            // This implicitly calls updateSearchResults to trigger the search
////        }
////    }
////}


//--------------------------------
import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    // 1. Two Separate Collection Views
    private var tagsCollectionView: UICollectionView!
    private var resultsCollectionView: UICollectionView!
    
    // Data Sources
    private var books: [Book] = []
    
    // Repository
    private let bookRepository = BookRepository()
    
    // Search Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    // Empty State
    private let emptyStateView: EmptyMyBooksViewController = EmptyMyBooksViewController(message: "No Result Found!", isButtonNeeded: false)
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setUpEmptyState()
        setUpTagsCollectionView()    // Setup View 1
        setUpResultsCollectionView() // Setup View 2
        setUpSearchController()
    }
    
    // MARK: - UI Setup
    
    private func setUpEmptyState() {
        addChild(emptyStateView)
        view.addSubview(emptyStateView.view)
        emptyStateView.didMove(toParent: self)
        
        emptyStateView.view.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.view.isHidden = true // Hidden by default
        
        NSLayoutConstraint.activate([
            emptyStateView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // Setup 1: The Tags (Recent/Categories) View
    private func setUpTagsCollectionView() {
        // Use your Custom LeftAligned Layout
        let layout = LeftAlignedFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        tagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagsCollectionView.backgroundColor = .systemBackground
        
        // Register Tag Cells
        tagsCollectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
        
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        let tagsTitleLabel = UILabel()
        view.addSubview(tagsTitleLabel)
        tagsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsTitleLabel.text = "Top Search"
        tagsTitleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        tagsTitleLabel.textColor = AppColors.title
        
        view.addSubview(tagsCollectionView)
        
        NSLayoutConstraint.activate([
            tagsTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tagsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            tagsTitleLable.widthAnchor.constraint(equalToConstant: 100),
            tagsTitleLabel.heightAnchor.constraint(equalToConstant: 50),
            tagsCollectionView.topAnchor.constraint(equalTo: tagsTitleLabel.bottomAnchor, constant: 5),
            tagsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setUpResultsCollectionView() {
        let layout = createCompositionalLayout()

        
        resultsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        resultsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        resultsCollectionView.backgroundColor = .systemBackground
        resultsCollectionView.isHidden = true // Start HIDDEN
        
        resultsCollectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
        
        resultsCollectionView.dataSource = self
        resultsCollectionView.delegate = self
        
        view.addSubview(resultsCollectionView)
        
        NSLayoutConstraint.activate([
            resultsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setUpSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search books, authors..."
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
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
    
    // MARK: - Search Logic (The Switching Mechanism)
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        if searchText.isEmpty {
            // STATE 1: No Text -> Show Tags
            tagsCollectionView.isHidden = false
            resultsCollectionView.isHidden = true
            emptyStateView.view.isHidden = true
        } else {
            // STATE 2: Typing -> Perform Search
            tagsCollectionView.isHidden = true // Hide tags immediately
            
            let result = bookRepository.searchBooks(searchText)
            
            switch result {
            case .success(let foundBooks):
                self.books = foundBooks
                
                if foundBooks.isEmpty {
                    // STATE 2a: No Results -> Show Empty State
                    resultsCollectionView.isHidden = true
                    emptyStateView.view.isHidden = false
                } else {
                    // STATE 2b: Has Results -> Show Results View
                    resultsCollectionView.isHidden = false
                    emptyStateView.view.isHidden = true
                }
                
                resultsCollectionView.reloadData()
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Check WHICH collection view is asking
        if collectionView == tagsCollectionView {
            return CategoryEnum.allCases.count
        } else {
            return books.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == tagsCollectionView {
            // Configure Tag Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath) as! CategoryPillCell
            let item = CategoryEnum.allCases[indexPath.item]
            cell.configure(title: item.rawValue, systemImageName: item.systemImageName)
            return cell
            
        } else {
            // Configure Result Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.layer.masksToBounds = true
            cell.configure(with: books[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == tagsCollectionView {
            // User tapped a Tag -> Fill Search Bar
            let category = CategoryEnum.allCases[indexPath.item]
            searchController.searchBar.text = category.rawValue
            // This automatically triggers updateSearchResults
            
        } else {
            // User tapped a Result -> Go to Details
            let book = books[indexPath.item]
            let vc = DetailViewController(book: book)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class LeftAlignedFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 1. Get the standard attributes from the parent class
        // (This is efficient because it only returns items in the visible rect)
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        // 2. Create a safe copy of the attributes to modify
        // (Modifying the original attributes directly can cause layout warnings)
        var leftAlignedAttributes = [UICollectionViewLayoutAttributes]()
        
        for attribute in attributes {
            if let copy = attribute.copy() as? UICollectionViewLayoutAttributes {
                leftAlignedAttributes.append(copy)
            }
        }
        
        // 3. Loop through and shift items to the left
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        for layoutAttribute in leftAlignedAttributes {
            
            // Check if this cell is on a new row
            // (We check if its Y position is lower than the previous known row)
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left // Reset margin for new row
            }
            
            // Shift the cell to the current left margin
            layoutAttribute.frame.origin.x = leftMargin
            
            // Calculate where the NEXT cell should start
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            
            // Update the vertical tracker
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return leftAlignedAttributes
    }
}
