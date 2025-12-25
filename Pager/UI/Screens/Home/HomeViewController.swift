//
//  HomeViewController.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import UIKit
import CoreData

enum HomeSection {
    case currently
    case recent
    case wantToRead
    case category(String, [Book])
}

class HomeViewController: UIViewController, UICollectionViewDelegate {
    private let profileButton = UIButton(type: .custom)
    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let viewModel = HomeViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTitleAndProfile()
        setupCollectionView()
        setupLoadingIndicator()
        setupBindings()
//        viewModel.loadData()
        //        loadDemoData()
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
                    if self?.viewModel.displayedSections.isEmpty ?? true {
                        self?.collectionView.isHidden = true
                    }
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
    
    private func setupTitleAndProfile() {
        profileButton.setImage(UIImage(systemName: "person"), for: .normal)//person.crop.circle.fill
        profileButton.tintColor = .label
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        navigationItem.title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 17.0, *) {
            navigationItem.largeTitleDisplayMode = .inline
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
        collectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
        collectionView.register(EmptyCurrentCell.self, forCellWithReuseIdentifier: "EmptyCurrentCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmptyHeader")
        
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, environment in
            if section == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                let groupSize : NSCollectionLayoutSize
                if self.viewModel.currentBook == nil {
                    groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.20))
                } else {
                    groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.35))
                    
                }
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .continuous
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top)
                sectionLayout.boundarySupplementaryItems = [header]
                return sectionLayout
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
    
    private func loadDemoData() {
        let demotemp = BookRepository()
        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
        switch sampleBooks {
        case .success(let books):
            viewModel.currentBook = books.first
            viewModel.wantToReadBooks = books
            viewModel.recentBooks = books
        case .failure(let error):
            print(error.localizedDescription)
            print(error)
        }
        collectionView.reloadData()
        
    }
    
    @objc func profileButtonTapped() {
        let vc = ProfileViewController()
        vc.hidesBottomBarWhenPushed = true
        
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            print("Profile tapped")
            
        }
    }
    
    func currentBookMoreTapped() {
        print("Current book menu tapped")
    }
    
    func emptyStateButtonTapped() {
        let bookStoreTabIndex = 2
        
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = bookStoreTabIndex
        } else {
            print("Error: EmptyMyBooksViewController is not managed by a Tab Bar Controller.")
        }
    }
    
    func bookCellTapped(book: Book) {
        
        //        let vc = SampleDataLoaderViewController()
        //        vc.modalPresentationStyle = .fullScreen
        //        present(vc, animated: true)
        //driver
        let vc = DetailViewController(book: book)
        vc.onDismiss = { [weak self] in
            self?.handleDismissal()
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func seeAllTapped(section: Int,title: String, books: [Book]) {
        let vc = BookGridViewController(categoryTitle: title, books: books)
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        print("See All tapped for section \(section)")
        
    }
    
    func handleDismissal() {
        if let _ = viewModel.onDataUpdated {
            viewModel.loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.displayedSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sec = viewModel.displayedSections[section]
        switch sec {
        case .currently:
            return 1
        case .recent:
            return viewModel.recentBooks.count
        case .wantToRead:
            return viewModel.wantToReadBooks.count
        case .category(_, let books):
            return books.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = viewModel.displayedSections[indexPath.section]
        switch section {
        case .currently:
            return configureCurrentCell(collectionView, indexPath: indexPath)
        case .recent:
            return configureRecentCell(collectionView, indexPath: indexPath)
        case .wantToRead:
            return configureWantToReadCell(collectionView, indexPath: indexPath)
        case .category(_, _):
            return configureCategoryCell(collectionView, indexPath: indexPath)
        }
    }
    
    func configureCurrentCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        if let book = viewModel.currentBook {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.layer.masksToBounds = true
            cell.configure(with: book)
            cell.moreButtonAction = { [weak self] in self?.currentBookMoreTapped() }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCurrentCell", for: indexPath) as! EmptyCurrentCell
            cell.configure(message: "You're not reading, go to Book Store", buttonTitle: "Book Store")
            cell.buttonAction = { [weak self] in self?.emptyStateButtonTapped() }
            return cell
        }
    }
    
    func configureRecentCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        let book = viewModel.recentBooks[indexPath.item]
        cell.configure(with: book)
        return cell
    }
    
    func configureWantToReadCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        let book = viewModel.wantToReadBooks[indexPath.item]
        cell.configure(with: book)
        return cell
    }
    
    func configureCategoryCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = viewModel.displayedSections[indexPath.section]
        
        if case .category(_, let books) = sectionType {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
            let book = books[indexPath.item]
            cell.configure(with: book)
            return cell
        }
        
        return UICollectionViewCell() // Fallback safety
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer) {
        guard let header = sender.view as? SectionHeaderView else { return }
        seeAllTapped(section: header.sectionIndex, title: header.title, books: header.books)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeaderView",
                for: indexPath) as! SectionHeaderView
            
            var title = ""
            var books: [Book] = []
            switch viewModel.displayedSections[indexPath.section] {
            case .currently:
                header.seeAllButton.isHidden = true
                if viewModel.currentBook == nil {
                    title = ""
                }
                else {
                    title = "Currently"
                }
            case .recent:
                header.seeAllButton.isHidden = false
                title = "Recent"
                books = viewModel.recentBooks
            case .wantToRead:
                header.seeAllButton.isHidden = false
                
                title = DefaultsName.wantToRead
                books = viewModel.wantToReadBooks
            case .category(let name, let bookList):
                header.seeAllButton.isHidden = false
                
                title = name
                books = bookList
            }
            header.titleLabel.text = title
            header.sectionIndex = indexPath.section
            header.title = title
            header.books = books
            
            header.seeAllAction = { [weak self] in
                self?.seeAllTapped(section: indexPath.section, title: title, books: books)
            }
            
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
//            guard let self = self else { return nil }
//            
//            let section = self.viewModel.displayedSections[indexPath.section]
//            var selectedBook: Book?
//            
//            switch section {
//            case .currently:
//                guard let book = self.viewModel.currentBook else { return nil }
//                selectedBook = book
//                
//            case .recent:
//                selectedBook = self.viewModel.recentBooks[indexPath.item]
//                
//            case .wantToRead:
//                selectedBook = self.viewModel.wantToReadBooks[indexPath.item]
//                
//            case .category(_, let books):
//                selectedBook = books[indexPath.item]
//            }
//            
//            guard let book = selectedBook else { return nil }
//            
//            let detailsAction = UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in
//                let vc = DetailViewController(book: book)
//                let nav = UINavigationController(rootViewController: vc)
//                nav.modalPresentationStyle = .fullScreen
//                self.present(nav, animated: true)
////                self.present(vc, animated: true, completion: nil)
//            }
//            
//            let wantToReadAction = UIAction(title: "Add to Want to Read", image: UIImage(systemName: "bookmark")) { _ in
//                switch self.viewModel.addBookToDefault(book: book)  {
//                case .success():
//                    self.viewModel.loadData()
//                case .failure(let error):
//                    if error == .bookAlreadyInCollection {
//                        let alert = UIAlertController(
//                            title: "Already Added",
//                            message: "This book is already in the selected collection.",
//                            preferredStyle: .alert
//                        )
//                        alert.addAction(UIAlertAction(title: "OK", style: .default))
//                        self.present(alert, animated: true)
//                    }
//                    print("Error: \(error)")
//                }
//                
//            }
//            
//            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
//            
//            let collectionItems = allCollections.map { collection in
//                UIAction(title: collection.name ?? "Untitled", image: UIImage(systemName: "folder")) { _ in
//                    switch self.viewModel.addBook(book, to: collection) {
//                    case .success():
//                        if collection.isDefault {
//                            self.viewModel.loadData()
//                        }
//                    case .failure(let error):
//                        if error == .bookAlreadyInCollection {
//                            let alert = UIAlertController(
//                                title: "Already Added",
//                                message: "This book is already in the selected collection.",
//                                preferredStyle: .alert
//                            )
//                            alert.addAction(UIAlertAction(title: "OK", style: .default))
//                            self.present(alert, animated: true)
//                        }
//                        print("Error: \(error)")
//                    }
//                }
//            }
//            
//            let addToCollectionMenu = UIMenu(
//                title: "Add to Collection",
//                image: UIImage(systemName: "folder.badge.plus"),
//                children: collectionItems
//            )
//            
//            return UIMenu(title: "", children: [
//                UIMenu(options: .displayInline, children: [detailsAction]),
//                UIMenu(options: .displayInline, children: [wantToReadAction, addToCollectionMenu])
//            ])
//        }
//    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            let section = self.viewModel.displayedSections[indexPath.section]
            var selectedBook: Book?
            
            switch section {
            case .currently:
                selectedBook = self.viewModel.currentBook
            case .recent:
                selectedBook = self.viewModel.recentBooks[indexPath.item]
            case .wantToRead:
                selectedBook = self.viewModel.wantToReadBooks[indexPath.item]
            case .category(_, let books):
                selectedBook = books[indexPath.item]
            }
            
            guard let book = selectedBook else { return nil }
            
            let detailsAction = UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in
                let vc = DetailViewController(book: book)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
            
            let isWantToRead = self.viewModel.isBookInCollection(book, collectionName: DefaultsName.wantToRead)
            
            let wantToReadAction = UIAction(
                title: isWantToRead ? "Remove from Want to Read" : "Add to Want to Read",
                image: UIImage(systemName: isWantToRead ? "bookmark.fill" : "bookmark"),
                attributes: []//isWantToRead ? .destructive : []
            ) { _ in
                if isWantToRead {
                    _ = self.viewModel.removeBookFromWantToRead(book: book)
                } else {
                    _ = self.viewModel.addBookToWantToRead(book: book)
                }
                self.viewModel.updateData()//driver
            }
            
            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
            
            let customCollections = allCollections.filter {
                $0.isDefault == false
            }
            
            let collectionItems = customCollections.map { collection in
                let isAdded = (collection.books as? Set<Book>)?.contains(book) ?? false
                
                return UIAction(
                    title: collection.name ?? "Untitled",
                    image: UIImage(systemName: "folder"),
                    state: isAdded ? .on : .off
                ) { _ in
                    if isAdded {
                        _ = self.viewModel.deleteFromCollection(collection: collection, book: book)
                    } else {
                        _ = self.viewModel.addBook(book, to: collection)
                    }
                }
            }
            
            let addToCollectionMenu = UIMenu(
                title: "Add to Collection",
                image: UIImage(systemName: "folder.badge.plus"),
                children: collectionItems
            )
            
            return UIMenu(title: "", children: [
                UIMenu(options: .displayInline, children: [detailsAction]),
                UIMenu(options: .displayInline, children: [wantToReadAction]),
                addToCollectionMenu
            ])
        }
    }
}
class SectionHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    let seeAllButton = UIButton(type: .system)
    let separatorView = UIView()
    var sectionIndex: Int = 0
    var title: String = ""
    var books: [Book] = []
    var seeAllAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        separatorView.backgroundColor = .systemGray4
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .left
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(.systemBlue, for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        addSubview(seeAllButton)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.addTarget(self, action: #selector(didTapSeeAll), for: .touchUpInside)
        
        // Layout: horizontal, padded
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: seeAllButton.leadingAnchor, constant: -8),
            
            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            seeAllButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTapSeeAll() {
        seeAllAction?()
    }
}
extension HomeViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = viewModel.displayedSections[indexPath.section]
        
        switch sectionType {
        case .currently:
            if let book = viewModel.currentBook {
                bookCellTapped(book: book)
            }
            
        case .recent:
            let book = viewModel.recentBooks[indexPath.item]
            bookCellTapped(book: book)
            
        case .wantToRead:
            let book = viewModel.wantToReadBooks[indexPath.item]
            bookCellTapped(book: book)
            
        case .category(_, let books):
            // FIX: No more (section - 3)
            let book = books[indexPath.item]
            bookCellTapped(book: book)
        }
    }
}
