//
//  ViewReviewViewController.swift
//  Pager
//
//  Created by Pradheep G on 19/12/25.
//
//
//import UIKit
//
//class ViewReviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
//
//    
//    private let collectionView: UICollectionView
//    private let review: Review
//    
//    init(review: Review) {
//        self.review = review
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 16
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
////        layout.itemSize = CGSize(width: 350, height: 200)
//        layout.estimatedItemSize = CGSize(width: 100, height: 500)
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = AppColors.background
//        title = "Reviews"
//        setUpReviewCollectionView()
//    }
//    
//    func setUpReviewCollectionView() {
//        view.addSubview(collectionView)
//        collectionView.backgroundColor = .clear
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.register(ReviewCell.self, forCellWithReuseIdentifier: "ReviewCell")
//        
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//        ])
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
//        cell.configure(with: review)
//        return cell
//    }
//}


import UIKit

class ViewReviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private let collectionView: UICollectionView
    private let review: Review
    private let staticCellHeight: CGFloat = 80

    init(review: Review) {
        self.review = review
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        layout.estimatedItemSize = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.gridViewBGColor
        title = "Review"
        setUpReviewCollectionView()
        setUpNavBarItem()
    }
    
    func setUpReviewCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ReviewCell.self, forCellWithReuseIdentifier: "ReviewCell")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        cell.configure(with: review, isDetailView: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.bounds.width - 32
        let textPaddingInternal: CGFloat = 32
        let availableTextWidth = cellWidth - textPaddingInternal
        
        let titleText = review.reviewTitle ?? ""
        let titleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
        let titleHeight = titleText.height(withConstrainedWidth: availableTextWidth, font: titleFont)
        
        let bodyText = review.reviewText ?? ""
        let bodyFont = UIFont.systemFont(ofSize: 16)
        let bodyHeight = bodyText.height(withConstrainedWidth: availableTextWidth, font: bodyFont)
        
        let writtenByText = review.postedBy?.profileName ?? ""
        let writtenByFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let writtenByHeight = writtenByText.height(
            withConstrainedWidth: availableTextWidth / 2,
            font: writtenByFont
        )
        let totalHeight = titleHeight + bodyHeight + writtenByHeight + staticCellHeight //+ 20
        
        return CGSize(width: cellWidth, height: totalHeight)
    }
    
    func setUpNavBarItem() {
        if isModal {
            let closeBarButton = UIBarButtonItem(barButtonSystemItem: .close,
                                                 target: self,
                                                 action: #selector(closeButtonTapped))
            
            navigationItem.leftBarButtonItems = [closeBarButton]
        }
    }
    @objc private func closeButtonTapped() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
