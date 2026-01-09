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
    case readingGoal
}

class HomeViewController: UIViewController, UICollectionViewDelegate {
    private let profileButton = UIButton(type: .custom)
    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let viewModel = HomeViewModel()
    private let readGoalService: ReadGoalService = ReadGoalService()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTitleAndProfile()
        setupCollectionView()
        setupLoadingIndicator()
        setupBindings()
//        edgesForExtendedLayout = [.top]
//        extendedLayoutIncludesOpaqueBars = true
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
                    self?.collectionView.isUserInteractionEnabled = false
                    if self?.viewModel.displayedSections.isEmpty ?? true {
                        self?.collectionView.isHidden = true
                    } else {
                        self?.collectionView.alpha = 0.5
                    }
                } else {
                    self?.collectionView.isHidden = false
                    self?.collectionView.alpha = 1
                    self?.collectionView.isUserInteractionEnabled = true
                    self?.activityIndicator.stopAnimating()

                }
            }
        }
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
//        viewModel.onWantToReadDataUpdated = { [weak self] in
//            DispatchQueue.main.async {
//                self?.collectionView.reloadSections(IndexSet(integer: (self?.viewModel.numberOfSections() ?? 1)-1))
//
//            }
//        }
        
        viewModel.onError = { [weak self] errorMessage in
            guard let self = self else {
                return
            }
            Toast.show(message: "Error loading home data: \(errorMessage)", in: self.view)
            DispatchQueue.main.async {
                print("Error loading home data: \(errorMessage)")
            }
        }
    }
    
    private func setupTitleAndProfile() {
        profileButton.setImage(UIImage(systemName: "person"), for: .normal)
        profileButton.tintColor = .label
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        navigationItem.title = "Home"
//        navigationController?.navigationBar.prefersLargeTitles = true
        
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithTransparentBackground()
//        appearance.backgroundColor = .clear
//        appearance.shadowColor = .clear
//
//        appearance.titleTextAttributes = [.foregroundColor: AppColors.title]
//        appearance.largeTitleTextAttributes = [.foregroundColor: AppColors.title]
//
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = appearance
//        navigationController?.navigationBar.compactAppearance = appearance
        if #available(iOS 17.0, *) {
            navigationItem.largeTitleDisplayMode = .inline
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = AppColors.gridViewBGColor
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
        collectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
        collectionView.register(EmptyCurrentCell.self, forCellWithReuseIdentifier: "EmptyCurrentCell")
        collectionView.register(ReadingGoalCell.self, forCellWithReuseIdentifier: ReadingGoalCell.reuseIdentifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmptyHeader")
        
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment in
            let section = self.viewModel.displayedSections[section]
            switch section {
            case .currently:
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
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 40, trailing: 0)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top)
                let backgroundItem = NSCollectionLayoutDecorationItem.background(
                    elementKind: GradientDecorationView.elementKind
                )
//                backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
                
                sectionLayout.decorationItems = [backgroundItem]
                sectionLayout.boundarySupplementaryItems = [header]
                return sectionLayout
            case .readingGoal:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(280))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 60, trailing: 10)
                let backgroundItem = NSCollectionLayoutDecorationItem.background(
                    elementKind: GradientDecorationView.elementKind
                )
                backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
                
                section.decorationItems = [backgroundItem]
                return section
            default:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.40), heightDimension: .absolute(250))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 0, bottom: 30, trailing: 0)
                
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
        Haptics.shared.play(.medium)
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
    
    func presentAdjustGoalScreen() {
        guard let user = UserSession.shared.currentUser else {
            return
        }
        let adjustVC = AdjustGoalViewController()
        
        adjustVC.currentGoalMinutes = Int(user.dailyReadingGoal)
        
        adjustVC.onGoalSelected = { [weak self] newMinutes in
            self?.readGoalService.updateDailyGoal(newGoal: newMinutes)
            self?.collectionView.reloadData()
        }
        
        if let sheet = adjustVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(adjustVC, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource, UITextFieldDelegate {
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
        case .readingGoal:
            return 1
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
        case .readingGoal:
            return configureReadingGoalCell(collectionView, indexPath: indexPath)
        }
    }
    
    func configureReadingGoalCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReadingGoalCell.reuseIdentifier, for: indexPath) as? ReadingGoalCell else {
            return UICollectionViewCell()
        }
        guard let user = UserSession.shared.currentUser else {
            return UICollectionViewCell()
        }
        
        let currentRead = readGoalService.getTodayReading()
        let currentGoal = user.dailyReadingGoal
        cell.configure(currentMinutes: currentRead, goalMinutes: Int(currentGoal), bookName: viewModel.currentBook?.title)
        
        cell.onAdjustGoalTapped = { [weak self] in
            self?.presentAdjustGoalScreen()
        }
        
        cell.onContinueReadingTapped = { [weak self] in
            guard let self = self else {
                return
            }//driver
            if let book = viewModel.currentBook {
                let vc = MainBookReaderViewController(book: book)
                vc.onDismiss = { [weak self] in
                    self?.handleDismissal()
                }
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
                
            } else {
                emptyStateButtonTapped()
            }
        }
        
        return cell
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
            case .readingGoal:
//                title = Reading Goal
                header.sectionIndex = indexPath.section
                header.title = "zczxcvzxvz"
                
                return header
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
//            if             viewModel.displayedSections[indexPath.section]

            return UICollectionReusableView()
        }
    }
 
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
            case .readingGoal:
                return nil
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
                title: "Want to Read",
                image: UIImage(systemName: isWantToRead ? "bookmark.fill" : "bookmark"),
                attributes: []//isWantToRead ? .destructive : []
            ) { _ in
                if isWantToRead {
                    self.showToast(result: self.viewModel.removeBookFromWantToRead(book: book),collectionName: DefaultsName.wantToRead,isAdded: !isWantToRead)
                } else {
                    self.showToast(result: self.viewModel.addBookToWantToRead(book: book),collectionName: DefaultsName.wantToRead,isAdded: !isWantToRead)
                }
                self.viewModel.updateData()//driver
            }
            
            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []

            let customCollections = allCollections
                .filter { $0.isDefault == false }
                .sorted {
                    ($0.createdAt ?? Date.distantPast) < ($1.createdAt ?? Date.distantPast)
                }
            var collectionItems = customCollections.map { collection in
                let isAdded = (collection.books)?.contains(book) ?? false
                
                return UIAction(
                    title: collection.name ?? "Untitled",
                    image: UIImage(systemName: isAdded ? "folder.fill": "folder"),
//                    state: isAdded ? .on : .off
                ) { _ in
                    if isAdded {
                        self.showToast(result: self.viewModel.deleteFromCollection(collection: collection, book: book),collectionName: collection.name,isAdded: !isAdded)
                    } else {
                        self.showToast(result: self.viewModel.addBook(book, to: collection), collectionName: collection.name, isAdded: !isAdded)
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
                setUpAddToCollectionView(book: book)
            ])
        }
    }
    
    func setUpAddToCollectionView(book: Book) -> UIAction {
        return UIAction(title: "Add to Collection",
                                           image: UIImage(systemName: "folder.badge.plus")) { [weak self] _ in
            guard let self = self else { return }
            let addToCollectionVC = AddToCollectionViewController(book: book)
            
            let nav = UINavigationController(rootViewController: addToCollectionVC)
            
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                
                sheet.prefersGrabberVisible = true
                
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            }
            
            self.present(nav, animated: true)
        }
        
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
    
    func showAddItemAlert(book: Book) {
        let alertController = UIAlertController(
            title: "Add New Collection",
            message: "Enter the name for the new Collection.",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Collection name"
            textField.delegate = self
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= ContentLimits.collectionMaxNameLength
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
        separatorView.isHidden = true
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .left
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(AppColors.systemBlue, for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        addSubview(seeAllButton)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.addTarget(self, action: #selector(didTapSeeAll), for: .touchUpInside)
        
        // Layout: horizontal, padded
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: seeAllButton.leadingAnchor, constant: -8),
            
            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            seeAllButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10)
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
            
        case .readingGoal:
            return
        }
    }
}
