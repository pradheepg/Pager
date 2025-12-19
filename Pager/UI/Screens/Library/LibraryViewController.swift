//
//  LibraryViewController.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import UIKit

class LibraryViewController: UIViewController {
    private let viewModel: LibraryViewModel = LibraryViewModel()
    private let segmentedControl: UISegmentedControl = UISegmentedControl(items: ["My Books", "Collections"])
    private let containerView: UIView = UIView()
    private let collectionTableView = BookCollectionViewController()
    private lazy var myBooksVC: MyBooksViewController = {
        let vc = MyBooksViewController(books: self.viewModel.myBooks)
        vc.didFinishTask = { [weak self] in
            print("The presented VC was dismissed!")
            self?.handleDismissal()
        }
        return vc
        }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Library"
        view.backgroundColor = AppColors.background
        setupSegmentedControl()
        setupContainerView()
        setupBindings()

        switchView(to: myBooksVC)
        viewModel.loadBooks()

    }
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            
            self.myBooksVC.update(books: self.viewModel.myBooks)
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.segmentChanged()
            }
            
        }
        
        viewModel.onError = { [weak self] errorMessage in
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.viewModel.myBooks = []
            self?.present(alert, animated: true)
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
            switchView(to: myBooksVC)
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
        if childVC is MyBooksViewController && viewModel.myBooks.isEmpty {
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
    
    
    func handleDismissal() {
        if let _ = viewModel.onDataUpdated {
            viewModel.loadBooks()
        }
        print("Parent received the message.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadBooks()
    }
}


//    func setUpData() {
//        let demotemp = BookRepository()
//        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
//        switch sampleBooks {
//        case .success(let books):
//            viewModel.myBooks = books
//        case .failure(let error):
//            print(error.localizedDescription)
//            print(error)
//        }
    //
    //    }
