//
//  SearchViewController.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//
import UIKit
internal import CoreData

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
        
    private var tagsCollectionView: UICollectionView!
    private var resultsCollectionView: UICollectionView!
    
    var collapsedSections = Set<Int>()
    let tagsTitleLabel = UILabel()

    let viewModel: SearchViewModel
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private let emptyStateView: EmptyMyBooksViewController = EmptyMyBooksViewController(message: "No Result Found!", isButtonNeeded: false)
    
    
    init() {
        self.viewModel = SearchViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"
        setUpEmptyState()
        setUpTagsCollectionView()
        setUpResultsCollectionView()
        setUpSearchController()
        setupNotificationObserver()
    }
    
    func setupNotificationObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    private func setUpEmptyState() {
        addChild(emptyStateView)
        view.addSubview(emptyStateView.view)
        emptyStateView.didMove(toParent: self)
        
        emptyStateView.view.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.view.isHidden = true
        
        NSLayoutConstraint.activate([
            emptyStateView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.view.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
    }
    
    private func setUpTagsCollectionView() {
        let layout = LeftAlignedFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        tagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagsCollectionView.backgroundColor = .systemBackground
        
        tagsCollectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
        
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        view.addSubview(tagsTitleLabel)
        tagsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsTitleLabel.text = "Category"
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
        resultsCollectionView.isHidden = true
        resultsCollectionView.keyboardDismissMode = .onDrag
        resultsCollectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
        resultsCollectionView.register(
                    CollapsibleCollectionHeader.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: CollapsibleCollectionHeader.reuseID
                )
        
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
        searchController.searchBar.placeholder = "Search books"
        searchController.obscuresBackgroundDuringPresentation = false
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
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
         header.pinToVisibleBounds = false //driver
        
        section.boundarySupplementaryItems = [header]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func addToken(for category: CategoryEnum) {
        let icon = UIImage(systemName: category.systemImageName)
        let token = UISearchToken(icon: icon, text: category.rawValue)
        token.representedObject = category
        
        searchController.searchBar.searchTextField.tokens = [token]
        searchController.searchBar.text = nil
        searchController.isActive = true
        updateSearchResults(for: searchController)
    }
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.showsCancelButton)
        let searchText = searchController.searchBar.text ?? ""
        let tokens = searchController.searchBar.searchTextField.tokens
        
        if searchText.isEmpty && tokens.isEmpty{
            tagsCollectionView.isHidden = false
            tagsTitleLabel.isHidden = tagsCollectionView.isHidden
            resultsCollectionView.isHidden = true
            emptyStateView.view.isHidden = true
        } else {
            tagsCollectionView.isHidden = true
            tagsTitleLabel.isHidden = tagsCollectionView.isHidden
            let result = viewModel.searchBooks(searchText: searchText, token: tokens)
            //driver
            switch result {
            case .success(let isEmpty):
//                let midpoint = (foundBooks.count + 1) / 2
//                self.viewModel.books = Array(foundBooks[..<midpoint])
//                self.viewModel.myBooks = Array(foundBooks[midpoint...])

                if isEmpty {
                    print(isEmpty)
                    resultsCollectionView.isHidden = true
                    emptyStateView.view.isHidden = false
                } else {
                    resultsCollectionView.isHidden = false
                    emptyStateView.view.isHidden = true
                }
                
                resultsCollectionView.reloadData()
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            resultsCollectionView.contentInset = .zero
        } else {
            let searchBarHeight = searchController.searchBar.frame.height
            let bottomInset = keyboardViewEndFrame.height - view.safeAreaInsets.bottom + searchBarHeight
//            emptyStateView.view.contentInset =
            resultsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
            
        }
        resultsCollectionView.scrollIndicatorInsets = resultsCollectionView.contentInset
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView  == resultsCollectionView {
            return 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagsCollectionView {
            return CategoryEnum.allCases.count
        } else {
            if collapsedSections.contains(section) {
                return 0
            }
            if section == 0 {
                return viewModel.myBooks.count
            } else {
                return viewModel.books.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == tagsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath) as! CategoryPillCell
            let item = CategoryEnum.allCases[indexPath.item]
            cell.configure(title: item.rawValue, systemImageName: item.systemImageName)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell


            if indexPath.section == 0 {
                cell.configure(with: viewModel.myBooks[indexPath.item])
                
            } else {
                cell.configure(with: viewModel.books[indexPath.item], isProgressHide: true)
                
            }
            return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == tagsCollectionView {
            let category = CategoryEnum.allCases[indexPath.item]
            addToken(for: category)
            
        } else {
            let book: Book
            if indexPath.section == 0 {
                book = viewModel.myBooks[indexPath.item]
            } else {
                book = viewModel.books[indexPath.item]
            }
            let vc = DetailViewController(book: book)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
//            present(vc, animated: true)
//            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if collectionView == tagsCollectionView {
                return UICollectionReusableView()
            }
//            if indexPath.section == 0 && viewModel.myBooks.isEmpty {
//                return UICollectionReusableView()
//            } else if indexPath.section == 1 && viewModel.books.isEmpty {
//                return UICollectionReusableView()
//            }//driver
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CollapsibleCollectionHeader.reuseID,
                for: indexPath
            ) as? CollapsibleCollectionHeader else {
                return UICollectionReusableView()
            }
            
            let isCollapsed = collapsedSections.contains(indexPath.section)
            let title = indexPath.section == 0 ? "My Books" : "Book Store"
            header.configure(title: title, isCollapsed: isCollapsed)
            header.onToggle = { [weak self] in
                guard let self = self else { return }
                
                if self.collapsedSections.contains(indexPath.section) {
                    self.collapsedSections.remove(indexPath.section) // Expand
                } else {
                    self.collapsedSections.insert(indexPath.section) // Collapse
                }
                
                self.resultsCollectionView.reloadSections(IndexSet(integer: indexPath.section))
            }
            
            return header
        }
        return UICollectionReusableView()
    }
    
    func makeContextMenu(for book: Book, isOwned: Bool) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else {
                return nil
            }
            let isWantToRead = viewModel.isBookInDefaultCollection(book, name: DefaultsName.wantToRead)
            
            let wantToReadAction = UIAction(
                title: DefaultsName.wantToRead,
                image: UIImage(systemName: isWantToRead ? "bookmark.fill" : "bookmark")
            ) { [weak self] _ in
                guard let self = self else { return }
                let result = self.viewModel.toggleDefaultCollection(book: book, collectionName: DefaultsName.wantToRead)
                self.showToast(result: result, collectionName: DefaultsName.wantToRead, isAdded: !isWantToRead)
                //            self.setupMoreMenu()
            }
            //
            //        let reviewAction = UIAction(title: "View Reviews", image: UIImage(systemName: "text.bubble")) { [weak self] _ in
            //            self?.reviewsSeeallButtonTapped()
            //        }
            //
            var menuItems: [UIMenuElement] = [
                UIMenu(options: .displayInline, children: [wantToReadAction]),
                
            ]
            if isOwned {
                let isFinished = viewModel.isBookInDefaultCollection(book, name: DefaultsName.finiahed)
                let finishedAction = UIAction(
                    title: isFinished ? "Mark as Unread" : "Mark as Completed",

                    image: UIImage(systemName: isFinished ? "checkmark.circle.fill" : "checkmark.circle")
                ) { [weak self] _ in
                    guard let self = self else { return }
                    let result = self.viewModel.toggleDefaultCollection(book: book, collectionName: DefaultsName.finiahed)
                    self.showToast(result: result, collectionName: DefaultsName.finiahed, isAdded: !isFinished)
                    //                self.setupMoreMenu()
                    
                }
                menuItems.append(UIMenu(options: .displayInline, children: [finishedAction]))
                
            }
            
            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
            
            let containingCollectionIDs = (book.collections as? Set<BookCollection>)?.map { $0.objectID } ?? []
            let containingSet = Set(containingCollectionIDs)
            
            var customCollectionActions = allCollections
                .filter { collection in
                    let name = collection.name ?? ""
                    return name != DefaultsName.wantToRead && name != DefaultsName.finiahed
                }
                .map { collection in
                    let isPresent = containingSet.contains(collection.objectID)
                    let collectionName = collection.name ?? "Untitled"
                    
                    return UIAction(
                        title: collectionName,
                        image: UIImage(systemName: isPresent ? "folder.fill" : "folder")
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        
                        if isPresent {
                            let result = self.viewModel.deleteFromCollection(collection: collection, book: book)
                            self.showToast(result: result, collectionName: collectionName, isAdded: false)
                        } else {
                            let result = self.viewModel.addBook(book, to: collection)
                            self.showToast(result: result, collectionName: collectionName, isAdded: true)
                        }
                        //                    self.setupMoreMenu()
                    }
                }
            
            let addCollection = UIAction(title: "Add New", image: UIImage(systemName: "plus")) {  _ in
                self.showAddItemAlert(book: book)
            }
            
            customCollectionActions.append(addCollection)
            let addToCollectionMenu = UIMenu(
                title: "Add to Collection",
                image: UIImage(systemName: "folder.badge.plus"),
                children: customCollectionActions
            )
            menuItems.append(UIMenu(options: .displayInline, children: [addToCollectionMenu]))
            
            return UIMenu(title: "", children: menuItems)
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section == 0 {
            return makeContextMenu(for: viewModel.myBooks[indexPath.row], isOwned: true)
        } else {
            return makeContextMenu(for: viewModel.books[indexPath.row], isOwned: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.isActive = true
            self.searchController.searchBar.becomeFirstResponder()
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

class CollapsibleCollectionHeader: UICollectionReusableView {
    static let reuseID = "CollapsibleCollectionHeader"
    
    var onToggle: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.up")
        iv.tintColor = AppColors.title
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(arrowImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.background
        titleLabel.textColor = AppColors.title
        titleLabel.backgroundColor = AppColors.background
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTapHeader() {
        onToggle?()
    }
    
    func configure(title: String, isCollapsed: Bool) {
        titleLabel.text = title
        
        let angle: CGFloat = isCollapsed ? .pi : 0
        
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}
