//
//  BookGridViewController.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//

import UIKit

class BookGridViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    private let collectionView: UICollectionView
    private let categoryTitle: String
    private var books: [Book] = []
    
    init(categoryTitle: String, books: [Book]) {
        self.categoryTitle = categoryTitle
        self.books = books
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
//        layout.estimatedItemSize = CGSize(width: 190, height: 310)
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
        print("njkadhfajafdawadsvfdsf")
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.background
        view.addSubview(collectionView)
        self.title = categoryTitle
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
}

extension BookGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookGridCell.reuseID, for: indexPath) as! BookGridCell
        cell.contentView.backgroundColor = AppColors.secondaryBackground
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        cell.configure(with: books[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = books[indexPath.item]
        let vc = DetailViewController(book: book)
        present(vc, animated: true, completion: .none)
        print("Tapped book:", book.bookId)
    }
    
    
    
    @objc func getButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let book = books[index]
        print("GET tapped for:", book.title)
    }
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
