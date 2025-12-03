//
//  LibraryViewController.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import UIKit

class LibraryViewController: UIViewController {
    private let segmentedControl: UISegmentedControl = UISegmentedControl(items: ["My Books", "Collections"])
    private let containerView: UIView = UIView()
    private let collectionTableView = BookCollectionViewController()
    private var myBooks: [Book] = []
    private let myCollections: [BookCollection] = []
    private lazy var myBooksCollectionView: MyBooksViewController = {
            return MyBooksViewController(books: self.myBooks)
        }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Library"
        view.backgroundColor = AppColors.background
        setUpData()
        setupSegmentedControl()
        setupContainerView()
        switchView(to: myBooksCollectionView)
    }
    
    func setUpData() {
        let demotemp = BookRepository()
        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
        switch sampleBooks {
        case .success(let books):
            myBooks = books
        case .failure(let error):
            print(error.localizedDescription)
            print(error)
        }

    }
    
    private func setupContainerView() {
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(containerView)
            
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
                containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    
    private func setupSegmentedControl() {
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func segmentChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            switchView(to: myBooksCollectionView)
        } else {
            switchView(to: collectionTableView)
        }
    }
    
    private func switchView(to childVC: UIViewController) {
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        var childVC = childVC
        if childVC is MyBooksViewController && myBooks.isEmpty {
            childVC = EmptyMyBooksViewController(message: "You haven’t purchased any books!", isButtonNeeded: true)
        }
        
        
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
        
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            childVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            childVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            childVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
//    private func setupEditButton() {
//        // 1. Create the system's "Edit" button
//        let editButton = self.editButtonItem
//        
//        // 2. Assign it to the right side of the navigation bar
//        navigationItem.rightBarButtonItem = editButton
//        
//        // 3. Optional: Wire it up to the table/collection view
//        // (You would need to implement setEditing in the LibraryViewController
//        // and pass the edit state down to the visible child table/collection view)
//    }
}
