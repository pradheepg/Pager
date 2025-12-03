//
//  BookStoreViewController.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

//import UIKit
//
//class BookStoreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
//    private let heroView = NewReleaseHeroView()
//    private var featuredBook: Book? = nil
//    private let categoryLable: UILabel = UILabel()
//    private let categoryCollectionView: UICollectionView
//    private var popularBook: [Book] = []
//    private var categories: [(name: String, books: [Book])] = []
//    private var collectionView: UICollectionView!
//    private let mainScrollView: UIScrollView = UIScrollView()
//    private let contentView = UIView()
//
//    init() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 8
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        self.categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        
//        let demotemp = BookRepository()
//        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
//        switch sampleBooks {
//        case .success(let books):
//            if let book = books.last {
//                featuredBook = book
//            }
//        case .failure(let error):
//            print(error.localizedDescription)
//            print(error)
//        }
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.title = "Book store"
//        setUpScrollView()
//        setUpHeroCard()
//        setUpCategory()
//        setupCollectionView()
//        loadDemoData()
//
//    }
//    
//    private func setUpScrollView() {
//        view.backgroundColor = AppColors.background
//        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(mainScrollView)
//        
//        NSLayoutConstraint.activate([
//            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//        ])
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        mainScrollView.addSubview(contentView)
//        
//        NSLayoutConstraint.activate([
//            contentView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
//        ])
//    }
//    
//    private func setUpHeroCard() {
//        guard let featuredBook = featuredBook else {
//            return
//        }
//        contentView.addSubview(heroView)
//        heroView.translatesAutoresizingMaskIntoConstraints = false
//        heroView.configure(with: featuredBook)
//        heroView.onButtonTapped = { [weak self] in
//            guard let self = self, let book = self.featuredBook else { return }
//            
//            let detailVC = DetailViewController(book: book)
//            self.navigationController?.pushViewController(detailVC, animated: true)
//        }
//        
//        NSLayoutConstraint.activate([
//            heroView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
//            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            heroView.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
//        ])
//        
//    }
//    
//    private func setUpCategory() {
//        contentView.addSubview(categoryLable)
//        categoryLable.text = "Categories"
//        categoryLable.font = .systemFont(ofSize: 20, weight: .semibold)
//        categoryLable.textColor = AppColors.title
//        categoryLable.translatesAutoresizingMaskIntoConstraints = false
//        
//        
//        contentView.addSubview(categoryCollectionView)
//        categoryCollectionView.showsHorizontalScrollIndicator = false
//        categoryCollectionView.backgroundColor = .clear
//        categoryCollectionView.register(CategoryPillCell.self,
//                                        forCellWithReuseIdentifier: CategoryPillCell.reuseID)
//        
//        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        categoryCollectionView.delegate = self
//        categoryCollectionView.dataSource = self
//        
//        
//        NSLayoutConstraint.activate([
//            categoryLable.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: 10),
//            categoryLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            categoryLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            categoryLable.heightAnchor.constraint(lessThanOrEqualToConstant: 30),
//            
//            categoryCollectionView.topAnchor.constraint(equalTo: categoryLable.bottomAnchor,constant: 10),
//            categoryCollectionView.leadingAnchor.constraint(equalTo: categoryLable.leadingAnchor),
//            categoryCollectionView.trailingAnchor.constraint(equalTo: categoryLable.trailingAnchor),
//            categoryCollectionView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
//            
//            
//        ])
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == categoryCollectionView {
//            return CategoryEnum.allCases.count
//        } else {
//            return categories[section].books.count
//        }
//    }
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        if collectionView == categoryCollectionView {
//            return 1
//        }
//        else {
//            return categories.count
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView == categoryCollectionView {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: CategoryPillCell.reuseID,
//                for: indexPath
//            ) as! CategoryPillCell
//            
//            let item = CategoryEnum.allCases[indexPath.item]
//            cell.configure(title: item.rawValue, systemImageName: item.systemImageName)
//            return cell
//        } else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.reuseID, for: indexPath) as! BookCell
//            
//            let item = categories[indexPath.section].books[indexPath.item]
//            cell.configure(with: item)
//            return cell
//        }
//    }
//    
//    
//    private func setupCollectionView() {
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = .clear
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        
//        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
//        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
//        
//        
//        contentView.addSubview(collectionView)
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 10),
//            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
//        ])
//    }
//    
//    private func createCompositionalLayout() -> UICollectionViewLayout {
//        return UICollectionViewCompositionalLayout { section, environment in
//            
//            let itemSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1),
//                heightDimension: .fractionalHeight(1)
//            )
//            
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
//            
//            let groupSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(0.63),
//                heightDimension: .fractionalWidth(0.63 * 1.5)
//            )
//            
//            let group = NSCollectionLayoutGroup.horizontal(
//                layoutSize: groupSize,
//                subitems: [item]
//            )
//            let sectionLayout = NSCollectionLayoutSection(group: group)
//            sectionLayout.orthogonalScrollingBehavior = .paging
//            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
//            let headerSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .absolute(40)
//            )
//            
//            let header = NSCollectionLayoutBoundarySupplementaryItem(
//                layoutSize: headerSize,
//                elementKind: UICollectionView.elementKindSectionHeader,
//                alignment: .top
//            )
//            
//            sectionLayout.boundarySupplementaryItems = [header]
//            
//            return sectionLayout
//        }
//    }
//    
//    private func loadDemoData() {
//        let demotemp = BookRepository()
//        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
//        switch sampleBooks {
//        case .success(let books):
//            popularBook = books
//        case .failure(let error):
//            print(error.localizedDescription)
//            print(error)
//        }
//        
//        var defaultCategoryName = "cat 1"
//        
//        categories.append((name: defaultCategoryName, books: popularBook))
//        defaultCategoryName = "cat 2"
//        categories.append((name: defaultCategoryName, books: popularBook))
//        defaultCategoryName = "cat 3"
//        categories.append((name: defaultCategoryName, books: popularBook))
//        defaultCategoryName = "cat 4"
//        categories.append((name: defaultCategoryName, books: popularBook))
//        
//        collectionView.reloadData()
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        viewForSupplementaryElementOfKind kind: String,
//                        at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionHeader {
//            let header = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: "SectionHeaderView",
//                for: indexPath) as! SectionHeaderView
//            
//            let title = categories[indexPath.section].name
//            let books: [Book] = categories[indexPath.section].books
//            header.titleLabel.text = title
//            header.sectionIndex = indexPath.section
//            header.title = title
//            header.books = books
//            
//            header.seeAllAction = { [weak self] in
//                self?.seeAllTapped(section: indexPath.section, title: title, books: books)
//            }
//            return header
//        } else {
//            return UICollectionReusableView()
//        }
//        
//    }
//    func seeAllTapped(section: Int,title: String, books: [Book]) {
//        let vc = BookGridViewController(categoryTitle: title, books: books)
//        self.navigationController?.pushViewController(vc, animated: true)
//        print("See All tapped for section \(section)")
//        
//    }
//}
import UIKit

class BookStoreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Sections Enum (Clean Architecture)
    enum SectionType: Int, CaseIterable {
        case hero = 0
        case categories = 1
        case books = 2 // This represents section index 2 and onwards
    }

    // MARK: - Data
private    var featuredBook: Book?
    private var popularBook: [Book] = []
    private var categories: [(name: String, books: [Book])] = []
    
    // MARK: - UI
    private var collectionView: UICollectionView!

    // MARK: - Lifecycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Book Store"
        navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 17.0, *) {
            navigationItem.largeTitleDisplayMode = .inline
        }
        setupCollectionView()
        loadDemoData()
    }
    
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        // Initialize with Compositional Layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear // or AppColors.background
        
        // --- Register Cells ---
        // Section 0: Hero
        collectionView.register(HeroContainerCell.self, forCellWithReuseIdentifier: HeroContainerCell.reuseID)
        // Section 1: Categories
        collectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
        // Section 2+: Books
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
        
        // --- Register Headers ---
        // Simple Header for "Categories" title
        collectionView.register(SimpleTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleTitleHeader.reuseID)
        // Complex Header with "See All" for books
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")

        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Compositional Layout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            
            if sectionIndex == 0 {
                // --- SECTION 0: HERO CARD ---
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                
                // Height 240 to match your Hero Card design (220 card + padding)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(220)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
                return section
                
            } else if sectionIndex == 1 {
                // --- SECTION 1: CATEGORY PILLS ---
                // Estimated width allows pills to resize based on text length
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .absolute(40)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                
                // Add "Categories" Title Header
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
                
            } else {
                // --- SECTION 2+: BOOK SHELVES ---
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                
                // Adjust width (0.45) to change book card size
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.40), heightDimension: .absolute(250))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 30, trailing: 10)
                
                // Add Section Header ("Sci-Fi", "History" etc)
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
    }

    // MARK: - Data Source
    
    // Total sections = Hero(1) + Categories(1) + BookShelves(N)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 + categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 } // Hero Card (always 1)
        if section == 1 { return CategoryEnum.allCases.count } // Categories
        
        // For book shelves (Section 2, 3, 4...)
        // We subtract 2 to get the index for our 'categories' array
        return categories[section - 2].books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            // --- HERO CELL ---
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroContainerCell.reuseID, for: indexPath) as! HeroContainerCell
            if let book = featuredBook {
                cell.configure(with: book) { [weak self] in
                    // Handle "Read Now" tap
                    guard let self = self else { return }
                    let detailVC = DetailViewController(book: book)
                    present(detailVC, animated: true, completion: nil)

//                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            }
            return cell
            
        } else if indexPath.section == 1 {
            // --- CATEGORY PILL CELL ---
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath) as! CategoryPillCell
            let item = CategoryEnum.allCases[indexPath.item]
            cell.configure(title: item.rawValue, systemImageName: item.systemImageName)
            return cell
            
        } else {
            // --- BOOK CELL ---
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
            let item = categories[indexPath.section - 2].books[indexPath.item]
            cell.configure(with: item)
            return cell
        }
    }
    
    // MARK: - Headers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            // Section 1 Header: "Categories" (Simple Title)
            if indexPath.section == 1 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SimpleTitleHeader.reuseID, for: indexPath) as! SimpleTitleHeader
                header.titleLabel.text = "Categories"
                return header
            }
            // Section 2+ Headers: "Sci-Fi", "Recent", etc (Complex Header)
            else if indexPath.section >= 2 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
                
                let dataIndex = indexPath.section - 2
                let title = categories[dataIndex].name
                let books = categories[dataIndex].books
                
                header.titleLabel.text = title
                header.seeAllAction = { [weak self] in
                    self?.seeAllTapped(section: indexPath.section, title: title, books: books)
                }
                return header
            }
        }
        return UICollectionReusableView()
    }
    
    func seeAllTapped(section: Int,title: String, books: [Book]) {
        let vc = BookGridViewController(categoryTitle: title, books: books)
        self.navigationController?.pushViewController(vc, animated: true)
        print("See All tapped for section \(section)")
        
    }
    
    private func loadDemoData() {
        let demotemp = BookRepository()
        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
        switch sampleBooks {
        case .success(let books):
            popularBook = books
            if let last = books.last { featuredBook = last }
        case .failure(let error):
            print(error)
        }
        
        // Mocking Data
        categories.append((name: "Trending Now", books: popularBook))
        categories.append((name: "Staff Picks", books: popularBook))
        categories.append((name: "Classics", books: popularBook))
        categories.append((name: "New Releases", books: popularBook))
        
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let featuredBook = featuredBook else {
                return
            }
            bookCellTapped(book: featuredBook)
        case 1:
            return
        default:
            print(indexPath.section, indexPath.item, indexPath.row)
            let book = categories[indexPath.section - 2]
            bookCellTapped(book: book.books[indexPath.item])
        }
        
    }
    func bookCellTapped(book: Book) {
        let vc = DetailViewController(book: book)
        present(vc, animated: true, completion: nil)
        print("Book '\(book.title)' tapped")
    }
}
