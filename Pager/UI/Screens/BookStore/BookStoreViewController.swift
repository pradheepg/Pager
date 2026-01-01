//
//  BookStoreViewController.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

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
        collectionView.backgroundColor = AppColors.gridViewBGColor

        collectionView.register(HeroContainerCell.self, forCellWithReuseIdentifier: HeroContainerCell.reuseID)
        collectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")

        collectionView.register(SimpleTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleTitleHeader.reuseID)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")

        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
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
                let backgroundItem = NSCollectionLayoutDecorationItem.background(
                    elementKind: GradientDecorationView.elementKind
                )
                backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
                
                section.decorationItems = [backgroundItem]
                return section
            }
        }
        layout.register(GradientDecorationView.self, forDecorationViewOfKind: GradientDecorationView.elementKind)
        return layout
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath) as! CategoryPillCell
            let item = CategoryEnum.allCases[indexPath.item]
            cell.configure(title: item.rawValue, systemImageName: item.systemImageName)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
            let item = viewModel.categories[indexPath.section - 2].books[indexPath.item]
            cell.configure(with: item)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            if indexPath.section == 1 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SimpleTitleHeader.reuseID, for: indexPath) as! SimpleTitleHeader
                header.titleLabel.text = "Categories"
                return header
            }
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
//                self.viewModel.loadData()
            }
            
            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
            
            let customCollections = allCollections.filter {
                $0.isDefault == false
            }
            
            var collectionItems = customCollections.map { collection in
                let isAdded = (collection.books as? Set<Book>)?.contains(book) ?? false
                
                return UIAction(
                    title: collection.name ?? "Untitled",
                    image: UIImage(systemName: isAdded ? "folder.fill" : "folder"),
//                    state: isAdded ? .on : .off
                ) { _ in
                    if isAdded {
                        _ = self.viewModel.deleteFromCollection(collection: collection, book: book)
                    } else {
                        _ = self.viewModel.addBook(book, to: collection)
                    }
                }
            }
            
            let addCollection = UIAction(title: "Add New", image: UIImage(systemName: "plus")) {  _ in
                self.showAddItemAlert(book: book)
            }
            collectionItems.append(addCollection)

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
    
    func showAddItemAlert(book: Book) {
        let alertController = UIAlertController(
            title: "Add New Collection",
            message: "Enter the name for the new Collection.",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Collection name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alertController.textFields?.first?.text,
                  !text.isEmpty else {
                return
            }
            
            self.addNewItem(name: text, book: book)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    func addNewItem(name: String, book: Book) {
        guard let _ = UserSession.shared.currentUser else { return }
        
        let result = viewModel.addNewCollection(as: name)
        
        switch result {
        case .success(let newCollection):
            
            switch viewModel.addBook(book, to: newCollection) {
            case .success(_):
                Toast.show(message: "Collection created and book added successfully ", in: self.view)
            case .failure(let error):
                print("error: \(error)")

            }

        case .failure(let error):
            
            if case .alreadyExists = error as? CollectionError {
                showNameExistsAlert(name: name)
            } else {
                print("Generic creation error: \(error)")
            }
        }
    }
    
    func showNameExistsAlert(name: String) {
        let alertController = UIAlertController(
            title: "Collection Already Exists!",
            message: "The Collection '\(name)' is already in your list. Please enter a different collection name.",
            preferredStyle: .alert
        )
        
        let dismissAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showToast(result: Result<Void,CollectionError>?, collectionName: String?, isAdded: Bool) {
        guard let result = result, let collectionName = collectionName else {
            return
        }
        switch result {
        case .success():
            Toast.show(message: "\(isAdded ? "Added to ":"Removed from ") \(collectionName)", in: self.view)
        case .failure(let error):
            print(error)
        }
    }
}
