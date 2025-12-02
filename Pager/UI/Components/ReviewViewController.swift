//
//  ReviewViewController.swift
//  Pager
//
//  Created by Pradheep G on 28/11/25.
//

import UIKit

class ReviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private let rootStackView: UIStackView = UIStackView()
    private let reviewCollectionView: UICollectionView
    private let book: Book
    private var reviews: [Review] = []
    private let ratingStackView: UIStackView = UIStackView()
    private let starButtonStack: UIStackView = UIStackView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.title = "Customer Reviews"
        view.backgroundColor = AppColors.background
        
        loadData()
        setUpNavBarItem()
        setupRatingsSection()
        if true {
            setRatingStackView()
        }
        setUpReviewCollectionView()
        
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 20),
            rootStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
//            rootStackView.heightAnchor.constraint(lessThanOrEqualToConstant: 500),//
            reviewCollectionView.topAnchor.constraint(equalTo: rootStackView.bottomAnchor, constant: 16),
            reviewCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reviewCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            reviewCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            reviewCollectionView.heightAnchor.constraint(equalToConstant: 220)//
        ])
        reviewCollectionView.reloadData()
    }
    
    init(book: Book) {
        self.book = book
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.itemSize = CGSize(width: 350, height: 200)
        reviewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRatingStackView() {
        rootStackView.addArrangedSubview(ratingStackView)
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .fill
        ratingStackView.alignment = .fill
        ratingStackView.spacing = 10
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let ratingLable: UILabel = UILabel()
        ratingStackView.addArrangedSubview(ratingLable)
        ratingLable.text = "Tap to Rate:"
        ratingLable.textColor = AppColors.title
        ratingLable.font = .systemFont(ofSize: 20, weight: .bold)
        
        ratingStackView.addArrangedSubview(starButtonStack)
        starButtonStack.axis = .horizontal
        starButtonStack.distribution = .fill
        starButtonStack.alignment = .fill
        starButtonStack.spacing = 10
        starButtonStack.translatesAutoresizingMaskIntoConstraints = false
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        
        for i in 1...5 {
            let starButton: UIButton = UIButton()
            starButtonStack.addArrangedSubview(starButton)
            starButton.setImage(UIImage(systemName: "star", withConfiguration: largeConfig), for: .normal)
            starButton.setImage(UIImage(systemName: "star.fill", withConfiguration: largeConfig), for: .selected)
            starButton.tintColor = .systemYellow
            starButton.tag = i
            starButton.addTarget(self, action: #selector(starTapped(_: )), for: .touchUpInside)
            starButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                starButton.widthAnchor.constraint(equalToConstant: 25),
                starButton.heightAnchor.constraint(equalToConstant: 25),
            ])
        }
    }
    
    func setUpNavBarItem() {
        let closeBarButton = UIBarButtonItem(barButtonSystemItem: .close,
                                            target: self,
                                            action: #selector(closeButtonTapped))

        navigationItem.leftBarButtonItems = [closeBarButton]
        
        if #available(iOS 26.0, *) {
            let editBarButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                                                style: .prominent,
                                                target: self,
                                                action: #selector(editButtonTapped))
            editBarButton.tintColor = AppColors.background
            navigationItem.rightBarButtonItems = [editBarButton]
        } else {
            let editBarButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(editButtonTapped))
            editBarButton.tintColor = AppColors.title
            navigationItem.rightBarButtonItems = [editBarButton]
        }
        
    }
    @objc private func closeButtonTapped() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func editButtonTapped() {
        let vc = ReviewEditViewController()
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    func setupRatingsSection() {
        view.addSubview(rootStackView)
        rootStackView.axis = .vertical
        rootStackView.distribution = .fill
        rootStackView.alignment = .fill
        rootStackView.spacing = 20
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let headerStackView: UIStackView = UIStackView()
        rootStackView.addArrangedSubview(headerStackView)
        headerStackView.axis = .horizontal
        headerStackView.distribution = .equalSpacing
        headerStackView.alignment = .fill
        headerStackView.spacing = 0
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel: UILabel = UILabel()
        headerStackView.addArrangedSubview(titleLabel)
        titleLabel.text = "Ratings & Reviews"
        titleLabel.textColor = AppColors.title
        titleLabel.font = .systemFont(ofSize: 25, weight: .bold)

        let summaryRowStackView: UIStackView = UIStackView()
        rootStackView.addArrangedSubview(summaryRowStackView)
        summaryRowStackView.axis = .horizontal
        summaryRowStackView.distribution = .fill
        summaryRowStackView.alignment = .fill
        summaryRowStackView.spacing = 0
        summaryRowStackView.translatesAutoresizingMaskIntoConstraints = false
        let averageRatingLable: UILabel = UILabel()
        summaryRowStackView.addArrangedSubview(averageRatingLable)
        averageRatingLable.text = String(book.averageRating)
        averageRatingLable.textColor = AppColors.title
        averageRatingLable.font = .systemFont(ofSize: 55, weight: .bold)

        
        let starProgressStack: UIStackView = UIStackView()
        summaryRowStackView.addArrangedSubview(starProgressStack)
        starProgressStack.axis = .horizontal
        starProgressStack.distribution = .equalCentering
        starProgressStack.alignment = .fill
        starProgressStack.spacing = 2
        starProgressStack.translatesAutoresizingMaskIntoConstraints = false
        
        let starStack: UIStackView = UIStackView()
        starProgressStack.addArrangedSubview(starStack)
        starStack.axis = .vertical
        starStack.distribution = .equalCentering
        starStack.alignment = .fill
        starStack.spacing = 2
        starStack.translatesAutoresizingMaskIntoConstraints = false
        setUpStarTriangle(starStack)
    

        let footerStackView: UIStackView = UIStackView()
        rootStackView.addArrangedSubview(footerStackView)
        footerStackView.axis = .horizontal
        footerStackView.distribution = .equalSpacing
        footerStackView.alignment = .fill
        footerStackView.spacing = 2
        footerStackView.translatesAutoresizingMaskIntoConstraints = false
        let outOfLable: UILabel = UILabel()
        footerStackView.addArrangedSubview(outOfLable)
        outOfLable.text = " out of 5 "
        outOfLable.textColor = AppColors.title
        outOfLable.font = .systemFont(ofSize: 20, weight: .semibold)
        let totalRatingLable: UILabel = UILabel()
        footerStackView.addArrangedSubview(totalRatingLable)
        totalRatingLable.text = String(book.reviews?.count ?? 0) + " Rating"
        totalRatingLable.textColor = AppColors.title
        totalRatingLable.font = .systemFont(ofSize: 20, weight: .regular)
        
    }
    
//    func setUpStarTriangle(_ starProgressStack: UIStackView) {
//        for i in stride(from: 5, to: 0, by: -1) {
//            let verticalStarStack: UIStackView = UIStackView()
//            starProgressStack.addArrangedSubview(verticalStarStack)
//            verticalStarStack.axis = .horizontal
//            verticalStarStack.distribution = .fill
//            verticalStarStack.alignment = .center
//            verticalStarStack.spacing = 0
//            verticalStarStack.translatesAutoresizingMaskIntoConstraints = false
//            for _ in stride(from: 0, to: 5-i, by: 1){
//                let guide = UIView()
//                guide.backgroundColor = .clear
//                verticalStarStack.addArrangedSubview(guide)
//            }
//            for _ in stride(from: 0, to: i, by: 1) {
//                let starIcon =  UIImageView(image: UIImage(systemName: "star.fill"))
//                starIcon.tintColor = .lightGray
//                starIcon.translatesAutoresizingMaskIntoConstraints = false
//                verticalStarStack.addArrangedSubview(starIcon)
//                NSLayoutConstraint.activate([
//                    starIcon.widthAnchor.constraint(equalToConstant: 12),
//                    starIcon.heightAnchor.constraint(equalToConstant: 12)
//                ])
//            }
//            let progressBar = UIProgressView(progressViewStyle: .bar)
//            verticalStarStack.addArrangedSubview(progressBar)
//            progressBar.translatesAutoresizingMaskIntoConstraints = false
//            progressBar.trackTintColor = .darkGray
//            progressBar.progressTintColor = .lightGray
//            progressBar.progress = 0.7
//            NSLayoutConstraint.activate([
//                progressBar.widthAnchor.constraint(equalToConstant: 200),
//                progressBar.heightAnchor.constraint(equalToConstant: 3)
//            ])
//        }
//    }
    func setUpStarTriangle(_ starStack: UIStackView) {
        // Loop for 5 rows (5 stars down to 1 star)
        for i in stride(from: 5, to: 0, by: -1) {
            
            let rowStack: UIStackView = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fill // Keep items at their natural size
            rowStack.alignment = .center
            rowStack.spacing = 2
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            
            // 1. Add Spacers (The "Guides")
            // We add invisible spacers so the stars align to the right side
            for _ in stride(from: 0, to: 5-i, by: 1) {
                let guide = UIView()
                guide.translatesAutoresizingMaskIntoConstraints = false
                rowStack.addArrangedSubview(guide)
                
                // CRITICAL FIX: Give the spacer a fixed width (same as a star)
                NSLayoutConstraint.activate([
                    guide.widthAnchor.constraint(equalToConstant: 12),
                    guide.heightAnchor.constraint(equalToConstant: 12)
                ])
            }
            
            // 2. Add Stars
            for _ in stride(from: 0, to: i, by: 1) {
                let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
                starIcon.tintColor = .lightGray // Changed to yellow for visibility
                starIcon.contentMode = .scaleAspectFit
                starIcon.translatesAutoresizingMaskIntoConstraints = false
                rowStack.addArrangedSubview(starIcon)
                
                NSLayoutConstraint.activate([
                    starIcon.widthAnchor.constraint(equalToConstant: 12),
                    starIcon.heightAnchor.constraint(equalToConstant: 12)
                ])
            }
            
            // 3. Add Progress Bar
            let progressBar = UIProgressView(progressViewStyle: .bar)
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            progressBar.trackTintColor = .systemGray5
            progressBar.progressTintColor = .darkGray
            progressBar.progress = 0.7 // Demo value
            progressBar.layer.cornerRadius = 2
            progressBar.clipsToBounds = true
            
            rowStack.addArrangedSubview(progressBar)
            
            // CRITICAL FIX: Add padding between stars and bar
            rowStack.setCustomSpacing(8, after: rowStack.arrangedSubviews[rowStack.arrangedSubviews.count - 2])

            // CRITICAL FIX: Set Width Priority to 999 to prevent crashes on small screens
            let widthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 150) // Reduced slightly to be safe
            widthConstraint.priority = UILayoutPriority(999)
            
            NSLayoutConstraint.activate([
                widthConstraint,
                progressBar.heightAnchor.constraint(equalToConstant: 4)
            ])
            
            starStack.addArrangedSubview(rowStack)
        }
    }
    
    func setUpReviewCollectionView() {
        view.addSubview(reviewCollectionView)
        reviewCollectionView.backgroundColor = .clear
        reviewCollectionView.showsHorizontalScrollIndicator = false
        reviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        reviewCollectionView.dataSource = self
        reviewCollectionView.delegate = self
        reviewCollectionView.register(ReviewCell.self, forCellWithReuseIdentifier: "ReviewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        cell.configure(with: reviews[indexPath.item])
        return cell
    }
    func loadData() {
        reviews = book.reviews?.allObjects as? [Review] ?? []
    }
    
    @objc func starTapped(_ sender: UIButton) {
        let selectedRating = sender.tag
        print("Star tapped: \(selectedRating)")
                for view in starButtonStack.arrangedSubviews {
            if let button = view as? UIButton {
                button.isSelected = button.tag <= selectedRating
            }
        }
    }
}
