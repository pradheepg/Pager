//
//  BookGridViewController.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//

import UIKit

class BookGridViewController: UIViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITextFieldDelegate {
    private let collectionView: UICollectionView
    private let searchBar: UISearchBar
    
    let viewModel: BookGridViewModel
    init(categoryTitle: String, books: [Book],currentCollection: BookCollection? = nil) {
        viewModel = BookGridViewModel(categoryTitle: categoryTitle, books: books, currentCollection: currentCollection)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.searchBar = UISearchBar()
        
        super.init(nibName: nil, bundle: nil)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(BookGridCell.self, forCellWithReuseIdentifier: BookGridCell.reuseID)
        self.collectionView.backgroundColor = AppColors.gridViewBGColor
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.keyboardDismissMode = .onDrag
        setUpSearchBar()
        setupUI()
        let _ = viewModel.searchBook(searchText: "")
        updateEmptyState()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        let _ = viewModel.searchBook(searchText: "")
        
        hideEmptyState()
        searchBar.setShowsCancelButton(false, animated: true)

        collectionView.reloadData()
    }
    
    private func setUpSearchBar() {
        view.addSubview(searchBar)
        searchBar.placeholder = "Search..."
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = .clear//AppColors.secondaryBackground
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
//        searchBar.showsCancelButton = true
        searchBar.searchTextField.enablesReturnKeyAutomatically = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            searchBar.heightAnchor.constraint(lessThanOrEqualToConstant: 40),
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.gridViewBGColor
        view.addSubview(collectionView)
        self.title = viewModel.categoryTitle
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    func prefersLargeTitles(_ bool: Bool){
        if #available(iOS 16.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = bool
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prefersLargeTitles(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        prefersLargeTitles(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let total = collectionView.bounds.width
        let availableWidth = total - 30
        let width = availableWidth / 2
        
        return CGSize(width: width, height: 310)
    }
    
    //todo hotfix here
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        searchBar.resignFirstResponder()
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            let book = self.viewModel.resultBooks[indexPath.item]
            
            
            let detailsAction = UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in
                let book = self.viewModel.resultBooks[indexPath.item]
                let vc = DetailViewController(book: book)
                vc.onDismiss = { [weak self] in
                    self?.refreshData()
                }
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
//                self.present(vc, animated: true, completion: .none)
            }
            
            let isAlreadyInWantToRead = self.viewModel.isBookInDefaultCollection(book)

            let wantToReadAction = UIAction(
                title: "Want to Read", //isAlreadyInWantToRead ? "Remove from Want to Read" : "Add to Want to Read",
                image: UIImage(systemName: isAlreadyInWantToRead ? "bookmark.fill" : "bookmark"),
                attributes: []//isAlreadyInWantToRead ? .destructive : []
            ) { [weak self] _ in
                guard let self = self else { return }
                
                if isAlreadyInWantToRead {
                    let result = self.viewModel.removeBookFromDefault(book: book)
                    
                    switch result {
                    case .success:
                        Toast.show(message: "Removed successfully", in: self.view)
                        if self.viewModel.currentCollection?.name == DefaultsName.wantToRead {
                            self.refreshData()
                        }
                        
                    case .failure(let error):
                        print("Error removing: \(error)")
                    }
                    
                } else {
                    let result = self.viewModel.addBookToDefault(book: book)
                    
                    switch result {
                    case .success:
                        Toast.show(message: "Added successfully", in: self.view)
                        if self.viewModel.currentCollection?.name == DefaultsName.wantToRead {
                            self.refreshData()
                        }
                        
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
                        print("Error adding: \(error)")
                    }
                }
            }

            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
            let customCollections = allCollections
                .filter { $0.isDefault == false }
                .sorted {
                    ($0.createdAt ?? Date.distantPast) < ($1.createdAt ?? Date.distantPast)
                }
            var collectionItems = customCollections
                .map { collection in
                    
                    let isAlreadyAdded = (collection.books)?.contains(book) ?? false
                    
                    let action = UIAction(
                        title: collection.name ?? "Untitled",
                        image: UIImage(systemName: isAlreadyAdded ? "folder.fill" : "folder"),
                        attributes: [],
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        
                        if isAlreadyAdded {
                            let result = self.viewModel.deleteFromCollection(collection: collection, book: book)
                            
                            switch result {
                            case .success:
                                Toast.show(message: "Successfully removed from \(collection.name ?? "")", in: self.view)
                            case .failure(let error):
                                print("Error removing: \(error)")
                            }
                            
                        } else {
                            let result = self.viewModel.addToCollection(collection: collection, book: book)
                            
                            switch result {
                            case .success:
                                Toast.show(message: "Successfully added to  \(collection.name ?? "")", in: self.view)
                            case .failure(let error):
                                if error == .bookAlreadyInCollection {
                                    print("Already in collection")
                                } else {
                                    print("Error adding: \(error)")
                                }
                            }
                        }
                    }
                    
                    return action
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
            var childCollection: [UIMenuElement] = []
            if viewModel.currentCollection?.name != DefaultsName.wantToRead {
                childCollection.append(wantToReadAction)
            }
            childCollection.append(addToCollectionMenu)
            var menuItems: [UIMenuElement] = [
                UIMenu(title: "", options: .displayInline, children: [detailsAction]),
                UIMenu(title: "", options: .displayInline, children: childCollection)
            ]

            if let collection = self.viewModel.currentCollection {
                let deleteAction = UIAction(title: "Remove from Collection", image: UIImage(systemName: "minus.circle"), attributes: .destructive) { _ in
                    let result = self.viewModel.deleteFromCollection(collection: collection, book: book)
                    
                    switch result {
                    case .success:
                        self.refreshData()
                        
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
                
                let deleteGroup = UIMenu(title: "", options: .displayInline, children: [deleteAction])
                
                menuItems.append(deleteGroup)
            }
            return UIMenu(title: "", children: menuItems)
        }
    }
    
    func refreshData() {
        self.viewModel.getUpdatedBookList()
        let currentSearch = searchBar.text ?? ""
        let _ = viewModel.searchBook(searchText: currentSearch)
        self.collectionView.reloadData()
        self.updateEmptyState()
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
            
            switch viewModel.addToCollection(collection: newCollection, book: book) {
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
    
    func updateEmptyState() {
        if viewModel.resultBooks.isEmpty {
            showEmptyState(message: "Your Collection is empty!")
        } else {
            hideEmptyState()
        }
    }

    private var emptyStateVC: UIViewController?

    private func showEmptyState(message: String, isButtonNeeded: Bool = true) {
        guard emptyStateVC == nil else { return }
        
        let vc = EmptyMyBooksViewController(message: message, isButtonNeeded: isButtonNeeded)
        
        addChild(vc)
        view.addSubview(vc.view)
        
//        vc.view.frame = collectionView.frame
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
        
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParent: self)
        
        emptyStateVC = vc
        collectionView.isHidden = true
    }

    private func hideEmptyState() {
        guard let vc = emptyStateVC else { return }
        
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
        emptyStateVC = nil
        collectionView.isHidden = false
    }
}

extension BookGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.resultBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookGridCell.reuseID, for: indexPath) as! BookGridCell
        cell.contentView.backgroundColor = AppColors.gridViewSecondaryColor
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        cell.configure(with: viewModel.resultBooks[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = viewModel.resultBooks[indexPath.item]
        let vc = DetailViewController(book: book)
        vc.onDismiss = { [weak self] in
            self?.refreshData()
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let result = viewModel.searchBook(searchText: searchText)
        switch result {
        case .success():
            hideEmptyState()
            collectionView.reloadData()
            updateEmptyState()
        case .failure(let error):
            if error == .noMatches {
                showEmptyState(message: "No result found!", isButtonNeeded: false)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= ContentLimits.collectionMaxNameLength
    }
    
}
