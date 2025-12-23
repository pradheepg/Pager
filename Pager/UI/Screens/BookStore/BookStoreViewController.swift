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

     enum SectionType: Int, CaseIterable {
        case hero = 0
        case categories = 1
        case books = 2
    }


    
    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let viewModel = BookStoreViewModel()
    
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
        setupLoadingIndicator()
        setupBindings()
        viewModel.loadData()
    }
    private func setupLoadingIndicator() {
        // Add indicator to the view, set constraints, and hide initially
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupBindings() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.collectionView.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.collectionView.isHidden = false
                }
            }
        }
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                print("Error loading home data: \(errorMessage)")
            }
        }
    }
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear // or AppColors.background

        collectionView.register(HeroContainerCell.self, forCellWithReuseIdentifier: HeroContainerCell.reuseID)
        collectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")

        collectionView.register(SimpleTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleTitleHeader.reuseID)
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
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            
            if sectionIndex == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(220)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
                return section
                
            } else if sectionIndex == 1 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .absolute(40)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
                
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.40), heightDimension: .absolute(250))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 30, trailing: 10)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
    }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 + viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 } // Hero Card (always 1)
        if section == 1 { return CategoryEnum.allCases.count } // Categories
        
        return viewModel.categories[section - 2].books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroContainerCell.reuseID, for: indexPath) as! HeroContainerCell
            if let book = viewModel.featuredBook {
                cell.configure(with: book) { [weak self] in
                    // Handle "Read Now" tap
                    guard let self = self else { return }
                    let detailVC = DetailViewController(book: book)
                    let nav = UINavigationController(rootViewController: detailVC)
                    nav.modalPresentationStyle = .fullScreen
                    present(nav, animated: true)
//                    present(detailVC, animated: true, completion: nil)

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
            let item = viewModel.categories[indexPath.section - 2].books[indexPath.item]
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
                let title = viewModel.categories[dataIndex].name
                let books = viewModel.categories[dataIndex].books
                
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
        vc.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(vc, animated: true)
        print("See All tapped for section \(section)")
        
    }
    
    private func loadDemoData() {
        let demotemp = BookRepository()
        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
        switch sampleBooks {
        case .success(let books):
            viewModel.popularBook = books
            if let last = books.last { viewModel.featuredBook = last }
        case .failure(let error):
            print(error)
        }
        
        // Mocking Data
        viewModel.categories.append((name: "Trending Now", books: viewModel.popularBook))
        viewModel.categories.append((name: "Staff Picks", books: viewModel.popularBook))
        viewModel.categories.append((name: "Classics", books: viewModel.popularBook))
        viewModel.categories.append((name: "New Releases", books: viewModel.popularBook))
        
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let featuredBook = viewModel.featuredBook else {
                return
            }
            bookCellTapped(book: featuredBook)
        case 1:
            let categoryData = viewModel.categories[indexPath.item]
            seeAllTapped(section: indexPath.section, title: categoryData.name, books: categoryData.books)
        default:
            print(indexPath.section, indexPath.item, indexPath.row)
            let book = viewModel.categories[indexPath.section - 2]
            bookCellTapped(book: book.books[indexPath.item])
        }
        
    }
    
    func bookCellTapped(book: Book) {
        let vc = DetailViewController(book: book)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
//        present(vc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            var selectedBook: Book?
            
            switch indexPath.section {
            case 0:
                selectedBook = self.viewModel.featuredBook
                
            case 1:
                return nil
                
            default:
                let categoryIndex = indexPath.section - 2
                if categoryIndex < self.viewModel.categories.count {
                    let books = self.viewModel.categories[categoryIndex].books
                    if indexPath.item < books.count {
                        selectedBook = books[indexPath.item]
                    }
                }
            }
            
            guard let book = selectedBook else { return nil }
            
            let detailsAction = UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in
                let vc = DetailViewController(book: book)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
//                self.present(vc, animated: true, completion: nil)
            }
            
            let wantToReadAction = UIAction(title: "Add to Want to Read", image: UIImage(systemName: "bookmark")) { _ in
//                guard let self = self else { return }

                switch self.viewModel.addBookToDefault(book: book) {
                case .success():
                    print("Adding")
                case .failure(let error):
                    if error == .bookAlreadyInCollection {
                        let alert = UIAlertController(
                            title: "Already Added",
                            message: "This book is already in the selected collection.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                    print("Error: \(error)")
                }
                print("Added to Want to Read: \(book.title ?? "")")
            }

            // 3. Collection Menu logic
            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
            
            let collectionItems = allCollections.map { collection in
                UIAction(title: collection.name ?? "Untitled", image: UIImage(systemName: "folder")) { _ in
                    // Add your logic here
                    print("Adding \(book.title ?? "") to collection: \(collection.name ?? "")")
                     switch self.viewModel.addBook(book, to: collection)  {
                     case .success():
                         print("Adding")
                     case .failure(let error):
                         if error == .bookAlreadyInCollection {
                             let alert = UIAlertController(
                                 title: "Already Added",
                                 message: "This book is already in the selected collection.",
                                 preferredStyle: .alert
                             )
                             alert.addAction(UIAlertAction(title: "OK", style: .default))
                             self.present(alert, animated: true)
                         }
                         print("Error: \(error)")
                     }
                }
            }
            
            let addToCollectionMenu = UIMenu(
                title: "Add to Collection",
                image: UIImage(systemName: "folder.badge.plus"),
                children: collectionItems
            )
            
            // 4. Construct Final Menu
            return UIMenu(title: "", children: [
                UIMenu(options: .displayInline, children: [detailsAction]),
                UIMenu(options: .displayInline, children: [wantToReadAction, addToCollectionMenu])
            ])
        }
    }
}
