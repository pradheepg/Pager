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
    private let ratingStackView: UIStackView = UIStackView()
    private let starButtonStack: UIStackView = UIStackView()
    private let viewModel: ReviewViewModel
    private let averageRatingLabel: UILabel = UILabel()
    private let starStack: UIStackView = UIStackView()
    private var totalRatingLabel: UILabel = UILabel()
    private var isOwned: Bool {
        guard let currentUser = UserSession.shared.currentUser,
              let ownedBooks = currentUser.owned?.allObjects as? [UserBookRecord] else {
            return false
        }
        return ownedBooks.contains(where: { $0.book == viewModel.book })
    }
    
    
    init(book: Book) {
        self.viewModel = ReviewViewModel(book: book)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        
        viewModel.loadData()
        setUpNavBarItem()
        setupRatingsSection()
        if true {
            setRatingStackView()
        }
        setUpReviewCollectionView()
        if let existingReview = viewModel.getCurrentUserReview() {
            let savedRating = Int(existingReview.rating)
            updateStarUI(rating: savedRating)
        }
        if !isOwned {
            starButtonStack.isUserInteractionEnabled = false
            starButtonStack.alpha = 0.5
        }
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 20),
            rootStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rootStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            reviewCollectionView.topAnchor.constraint(equalTo: rootStackView.bottomAnchor, constant: 16),
            reviewCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reviewCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            reviewCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        reviewCollectionView.reloadData()
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
        if isOwned {
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
        
    }
    @objc private func closeButtonTapped() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func editButtonTapped() {
        let vc = EditReviewViewController(book: viewModel.book)
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
        summaryRowStackView.addArrangedSubview(averageRatingLabel)
        averageRatingLabel.text = String(viewModel.book.averageRating)
        averageRatingLabel.textColor = AppColors.title
        averageRatingLabel.font = .systemFont(ofSize: 55, weight: .bold)
        
        
        let starProgressStack: UIStackView = UIStackView()
        summaryRowStackView.addArrangedSubview(starProgressStack)
        starProgressStack.axis = .horizontal
        starProgressStack.distribution = .equalCentering
        starProgressStack.alignment = .fill
        starProgressStack.spacing = 2
        starProgressStack.translatesAutoresizingMaskIntoConstraints = false
        
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
        footerStackView.addArrangedSubview(totalRatingLabel)
        totalRatingLabel.text = String(viewModel.book.reviews?.count ?? 0) + " Rating"
        totalRatingLabel.textColor = AppColors.title
        totalRatingLabel.font = .systemFont(ofSize: 20, weight: .regular)
        
    }
    
    func setUpStarTriangle(_ starStack: UIStackView) {
        for i in stride(from: 5, to: 0, by: -1) {
            
            let rowStack: UIStackView = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fill
            rowStack.alignment = .center
            rowStack.spacing = 2
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            
            for _ in stride(from: 0, to: 5-i, by: 1) {
                let guide = UIView()
                guide.translatesAutoresizingMaskIntoConstraints = false
                rowStack.addArrangedSubview(guide)
                
                NSLayoutConstraint.activate([
                    guide.widthAnchor.constraint(equalToConstant: 12),
                    guide.heightAnchor.constraint(equalToConstant: 12)
                ])
            }
            
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
            
            let progressBar = UIProgressView(progressViewStyle: .bar)
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            progressBar.trackTintColor = .systemGray5
            progressBar.progressTintColor = .darkGray
            progressBar.progress = viewModel.getProgress(for: i)
            progressBar.layer.cornerRadius = 2
            progressBar.clipsToBounds = true
            
            rowStack.addArrangedSubview(progressBar)
            
            rowStack.setCustomSpacing(8, after: rowStack.arrangedSubviews[rowStack.arrangedSubviews.count - 2])
            
            let widthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 150)
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
        return viewModel.reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        cell.configure(with: viewModel.reviews[indexPath.item])
        return cell
    }
    
    @objc func starTapped(_ sender: UIButton) {
        updateTotalRatingText()
        let selectedRating = sender.tag
        let result = viewModel.submitReview(rating: selectedRating)
        switch result {
        case .success:
            updateStarUI(rating: selectedRating)
            refreshHeaderUI()
            reviewCollectionView.reloadData()
            
        case .failure(let error):
            print("Error: \(error)")
        }
    }
    
    func updateStarUI(rating: Int) {
        for view in starButtonStack.arrangedSubviews {
            if let button = view as? UIButton {
                button.isSelected = button.tag <= rating
            }
        }
    }
    
    func refreshHeaderUI() {
        averageRatingLabel.text = String(format: "%.1f", viewModel.book.averageRating)
        updateTotalRatingText()
        
        starStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        setUpStarTriangle(starStack)
    }
    
    private func updateTotalRatingText() {
        totalRatingLabel.text = "\(viewModel.totalRating) Ratings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
        
        reviewCollectionView.reloadData()
        
        refreshHeaderUI()
        
        if let existingReview = viewModel.getCurrentUserReview() {
            let savedRating = Int(existingReview.rating)
            updateStarUI(rating: savedRating)
        } else {
            updateStarUI(rating: 0)
        }
    }
}
