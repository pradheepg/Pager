//
//  BookGridViewController.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//

import UIKit

class BookGridViewController: UIViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
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
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            let book = self.viewModel.resultBooks[indexPath.item]

            
            let detailsAction = UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in
                let book = self.viewModel.resultBooks[indexPath.item]
                let vc = DetailViewController(book: book)
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
                            self.viewModel.getUpdatedBookList()
                            self.collectionView.reloadData()
                            self.updateEmptyState()
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
                            self.viewModel.getUpdatedBookList()
                            self.collectionView.reloadData()
                            self.updateEmptyState()
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
//            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
//            
//
//            
//            let collectionItems = allCollections
//                .filter { $0 != self.viewModel.currentCollection }
//                .map { collection in
//                    UIAction(title: collection.name ?? "Untitled", image: UIImage(systemName: "folder")) { _ in
//                        let result = self.viewModel.addToCollection(collection: collection, book: book)
//                        switch result {
//                        case .success:
//                            print("Success")
//                            //                            self.viewModel.getUpdatedBookList()
//                            //                            self.collectionView.reloadData()
//                            //                            self.updateEmptyState()
//                            
//                        case .failure(let error):
//                            if error == .bookAlreadyInCollection {
//                                let alert = UIAlertController(
//                                    title: "Already Added",
//                                    message: "This book is already in the selected collection.",
//                                    preferredStyle: .alert
//                                )
//                                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                                self.present(alert, animated: true)
//                            }
//                            print("Error: \(error)")
//                        }
//                    }
//                }
            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []

            let collectionItems = allCollections
                .filter { collection in
                    let isCurrent = collection == self.viewModel.currentCollection
                    return !isCurrent && !collection.isDefault
                }
                .map { collection in
                    
                    let isAlreadyAdded = (collection.books as? Set<Book>)?.contains(book) ?? false
                    
                    let action = UIAction(
                        title: collection.name ?? "Untitled",
                        image: UIImage(systemName: isAlreadyAdded ? "folder.fill" : "folder"),
                        attributes: [],
//                        state: isAlreadyAdded ? .on : .off
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        
                        if isAlreadyAdded {
                            let result = self.viewModel.deleteFromCollection(collection: collection, book: book)
                            
                            switch result {
                            case .success:
                                print("Successfully removed from \(collection.name ?? "")")
//                                collectionView.reloadData()
                            case .failure(let error):
                                print("Error removing: \(error)")
                            }
                            
                        } else {
                            let result = self.viewModel.addToCollection(collection: collection, book: book)
                            
                            switch result {
                            case .success:
                                print("Successfully added to \(collection.name ?? "")")
                                
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
            
            let addToCollectionMenu = UIMenu(
                title: "Add to Collection",
                image: UIImage(systemName: "folder.badge.plus"),
                children: collectionItems
            )
            var menuItems: [UIMenuElement] = [
                UIMenu(title: "", options: .displayInline, children: [detailsAction]),
                UIMenu(title: "", options: .displayInline, children: [wantToReadAction, addToCollectionMenu])
            ]

            if let collection = self.viewModel.currentCollection {
                let deleteAction = UIAction(title: "Remove from Collection", image: UIImage(systemName: "minus.circle"), attributes: .destructive) { _ in
                    let result = self.viewModel.deleteFromCollection(collection: collection, book: book)
                    
                    switch result {
                    case .success:
                        self.viewModel.getUpdatedBookList()
                        self.collectionView.reloadData()
                        self.updateEmptyState()
                        
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
    
}
