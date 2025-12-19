//
//  BookGridViewController.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//

import UIKit

class BookGridViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    private let collectionView: UICollectionView
    let viewModel: BookGridViewModel
    init(categoryTitle: String, books: [Book],currentCollection: BookCollection? = nil) {
        viewModel = BookGridViewModel(categoryTitle: categoryTitle, books: books, currentCollection: currentCollection)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(BookGridCell.self, forCellWithReuseIdentifier: BookGridCell.reuseID)
        self.collectionView.backgroundColor = AppColors.background
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateEmptyState()
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.background
        view.addSubview(collectionView)
        self.title = viewModel.categoryTitle
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    func prefersLargeTitles(_ bool: Bool){
        if #available(iOS 17.0, *) {
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
            
            let book = self.viewModel.books[indexPath.item]

            
            let detailsAction = UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { _ in
                let book = self.viewModel.books[indexPath.item]
                let vc = DetailViewController(book: book)
                self.present(vc, animated: true, completion: .none)
                 // self.showBookDetails(book)
            }
            
            let wantToReadAction = UIAction(title: "Add to Want to Read", image: UIImage(systemName: "bookmark")) { _ in
                 // self.viewModel.addToWantToRead(book)
            }

            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
            

            
            let collectionItems = allCollections
                .filter { $0 != self.viewModel.currentCollection }
                .map { collection in
                    UIAction(title: collection.name ?? "Untitled", image: UIImage(systemName: "folder")) { _ in
                        let result = self.viewModel.addToCollection(collection: collection, book: book)
                        switch result {
                        case .success:
                            print("Success")
                            //                            self.viewModel.getUpdatedBookList()
                            //                            self.collectionView.reloadData()
                            //                            self.updateEmptyState()
                            
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
            var menuItems: [UIMenuElement] = [
                UIMenu(title: "", options: .displayInline, children: [detailsAction]),
                UIMenu(title: "", options: .displayInline, children: [wantToReadAction, addToCollectionMenu])
            ]

            if let collection = viewModel.currentCollection {
                let deleteAction = UIAction(title: "Remove from Collection", image: UIImage(systemName: "minus.circle"), attributes: .destructive) { _ in
                    let result = self.viewModel.deleteFromCollection(collection: collection, book: book)
                    
                    switch result {
                    case .success:
                        print("Book removed")
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
        if viewModel.books.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }

    private var emptyStateVC: UIViewController?

    private func showEmptyState() {
        guard emptyStateVC == nil else { return }
        
        let vc = EmptyMyBooksViewController(message: "Your Collection is empty!", isButtonNeeded: true)
        
        addChild(vc)
        view.addSubview(vc.view)
        
        vc.view.frame = view.bounds
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
        return viewModel.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookGridCell.reuseID, for: indexPath) as! BookGridCell
        cell.contentView.backgroundColor = AppColors.secondaryBackground
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        cell.configure(with: viewModel.books[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = viewModel.books[indexPath.item]
        let vc = DetailViewController(book: book)
        present(vc, animated: true, completion: .none)
    }
    
//    
//    
//    @objc func getButtonTapped(_ sender: UIButton) {
//        let index = sender.tag
//        let book = viewModel.books[index]
//        print("GET tapped for:", book.title)
//    }
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .darkContent
////        if userInterfaceStyle
////        return UIColor { trait in
////            trait.userInterfaceStyle == .dark
////                ? UIColor.black
////                : UIColor.white
////        }
//    }
    
}
