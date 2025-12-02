//
//  DetailViewController.swift
//  Pager
//
//  Created by Pradheep G on 26/11/25.
//

import UIKit

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        cell.configure(with: reviews[indexPath.item])
        return cell
    }

    private let mainScrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    private let coverImageView = UIView()
    private let coverImage: UIImageView = UIImageView()
    private let bookNameLable: UILabel = UILabel()
    private let authorNameLable: UILabel = UILabel()
    private let getReadButton: UIButton = UIButton(type: .system)
    private let wantToReadButton: UIButton = UIButton()
    private let descriptionView: UIView = UIView()
    private let descriptionTitleLable: UILabel = UILabel()
    private let descriptionContentLable: UILabel = UILabel()
    private let otherInfoStack: UIStackView = UIStackView()
    private let reviewCollectionView: UICollectionView
    private let ratingStackView: UIStackView = UIStackView()
    private let rootStackView: UIStackView = UIStackView()

    
    private let starButtonStack: UIStackView = UIStackView()

    

    private var reviews: [Review] = []

    private let book: Book
    
    init(book: Book) {
        self.book = book
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.itemSize = CGSize(width: 350, height: 200)

//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        reviewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadSameData()
        loadData()
        setUpScrollView()
        setUpStackView()
        setUpContent()

    }
    func loadSameData() {
        let repoDemo = ReviewRepository()
        let temptemp = repoDemo.fetchReviews(for: book)
        switch temptemp {
        case .success(let resu):
            if let ejdladla = resu.first{
                repoDemo.deleteReview(ejdladla)
            }
            
        default:
            print("Nother")
        }
        repoDemo.createReview(for: book, by: UserSession.shared.currentUser!, rating: 4, title: "Best bookhat is what i tell ", text: "Omg that is what i tell ,you know what i telling know ,right omg and that little showing off what he is telling you ok so behat is what i tell ,you know what i telling know ,right omg and that little showing off but i will be there for you and that what he is telling you ok so be happy")
    }
    func loadData() {
        reviews = book.reviews?.allObjects as? [Review] ?? []
    }
    
    private func setUpScrollView() {
        view.backgroundColor = AppColors.background
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainScrollView)
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
        ])
    }
    private func setUpStackView() {
        contentView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.alignment = .center
        mainStackView.distribution = .fill

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor,constant: 30),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setUpReviewCollectionView() {
        mainStackView.addArrangedSubview(reviewCollectionView)
        reviewCollectionView.backgroundColor = .clear
        reviewCollectionView.showsHorizontalScrollIndicator = false
        reviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        reviewCollectionView.dataSource = self
        reviewCollectionView.delegate = self
        reviewCollectionView.register(ReviewCell.self, forCellWithReuseIdentifier: "ReviewCell")
//        reviewCollectionView.register(DemoCell.self, forCellWithReuseIdentifier: "DemoCell")



    }
    
    func setUpContent() {
        mainStackView.addArrangedSubview(coverImageView)
        mainStackView.addArrangedSubview(bookNameLable)
        mainStackView.addArrangedSubview(authorNameLable)
        mainStackView.addArrangedSubview(getReadButton)
        let verticalSeparator1 = makeVerticalSeparator()
        mainStackView.addArrangedSubview(verticalSeparator1)
        mainStackView.addArrangedSubview(descriptionView)
        let verticalSeparator2 = makeVerticalSeparator()
        mainStackView.addArrangedSubview(verticalSeparator2)



        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.backgroundColor = AppColors.background
        coverImage.contentMode = .scaleAspectFill
        coverImage.layer.masksToBounds = true
        coverImage.image = ViewHelper.getCoverImage(of: book)
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.addSubview(coverImage)
        
        bookNameLable.text = book.title
        bookNameLable.textAlignment = .center
        bookNameLable.font = UIFont.boldSystemFont(ofSize: 25)
        bookNameLable.numberOfLines = 0
        bookNameLable.translatesAutoresizingMaskIntoConstraints = false
        
        authorNameLable.text = book.author
        authorNameLable.textAlignment = .center
        authorNameLable.font = UIFont.systemFont(ofSize: 15)
        authorNameLable.numberOfLines = 0
        authorNameLable.translatesAutoresizingMaskIntoConstraints = false
        
        getReadButton.setTitle("GET", for: .normal)
        getReadButton.setTitleColor(AppColors.background, for: .normal)
        getReadButton.backgroundColor = AppColors.title
        getReadButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        getReadButton.translatesAutoresizingMaskIntoConstraints = false
        getReadButton.layer.cornerRadius = 24
        getReadButton.layer.masksToBounds = true
        
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.backgroundColor = AppColors.background
        
        descriptionTitleLable.text = "Publisher Description"
        descriptionTitleLable.textAlignment = .left
        descriptionTitleLable.font = UIFont.boldSystemFont(ofSize: 15)
        descriptionTitleLable.numberOfLines = 0
        descriptionTitleLable.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.addSubview(descriptionTitleLable)
        
        descriptionContentLable.text = book.descriptionText
        descriptionContentLable.textAlignment = .left
        descriptionContentLable.font = UIFont.systemFont(ofSize: 12)
        descriptionContentLable.numberOfLines = 0
        descriptionContentLable.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.addSubview(descriptionContentLable)
        
        setUpOtherInfoStack()
        let verticalSeparator3 = makeVerticalSeparator()
        mainStackView.addArrangedSubview(verticalSeparator3)
        setupRatingsSection()
        if true {
            setRatingStackView()
        }
        setUpReviewCollectionView()

        
        NSLayoutConstraint.activate([
            coverImageView.heightAnchor.constraint(equalToConstant: 440),
            coverImageView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.8),
            
            coverImage.centerXAnchor.constraint(equalTo: coverImageView.centerXAnchor),
            coverImage.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor),
            coverImage.widthAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 0.9),
            coverImage.heightAnchor.constraint(equalTo: coverImage.widthAnchor, multiplier: 3/2),
            
            getReadButton.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            getReadButton.heightAnchor.constraint(equalToConstant: 50),
            
            
            verticalSeparator1.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            verticalSeparator1.heightAnchor.constraint(lessThanOrEqualToConstant: 50),
            
            descriptionView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            descriptionView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            descriptionTitleLable.topAnchor.constraint(equalTo: descriptionView.topAnchor),
            descriptionTitleLable.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor),
            descriptionTitleLable.bottomAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 20),
            
            descriptionContentLable.topAnchor.constraint(equalTo: descriptionTitleLable.bottomAnchor),
            descriptionContentLable.leadingAnchor.constraint(equalTo: descriptionTitleLable.leadingAnchor),
            descriptionContentLable.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor),
            descriptionContentLable.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor),
            
            verticalSeparator2.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            verticalSeparator2.heightAnchor.constraint(lessThanOrEqualToConstant: 50),
            
            otherInfoStack.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            otherInfoStack.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            verticalSeparator3.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            verticalSeparator3.heightAnchor.constraint(lessThanOrEqualToConstant: 50),
            
            rootStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            rootStackView.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
            
            reviewCollectionView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            reviewCollectionView.heightAnchor.constraint(equalToConstant: 200 ),
            
        ])
    }
    
    func setRatingStackView() {
        mainStackView.addArrangedSubview(ratingStackView)
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
        
        
        NSLayoutConstraint.activate([
            ratingStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            ratingStackView.heightAnchor.constraint(lessThanOrEqualToConstant: 300),
        ])
    }
    
    func setupRatingsSection() {
        mainStackView.addArrangedSubview(rootStackView)
        rootStackView.axis = .vertical
        rootStackView.distribution = .fillProportionally
        rootStackView.alignment = .fill
        rootStackView.spacing = 10
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
        let seeAllButton: UIButton = UIButton()
        headerStackView.addArrangedSubview(seeAllButton)
        seeAllButton.setTitle("SeeAll", for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        seeAllButton.addTarget(self, action: #selector(reviewsSeeallButtonTapped), for: .touchUpInside)
        seeAllButton.setTitleColor(AppColors.title, for: .normal)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false

        let summaryRowStackView: UIStackView = UIStackView()
        rootStackView.addArrangedSubview(summaryRowStackView)
        summaryRowStackView.axis = .horizontal
        summaryRowStackView.distribution = .equalSpacing
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
    
    func setUpOtherInfoStack() {
        mainStackView.addArrangedSubview(otherInfoStack)
        otherInfoStack.axis = .horizontal
        otherInfoStack.distribution = .fillProportionally
        otherInfoStack.alignment = .fill
        otherInfoStack.spacing = 0
        otherInfoStack.translatesAutoresizingMaskIntoConstraints = false
        
        let genreView    = makeInfoColumn(title: "Genre",    main: "", subtitle: book.genre, icon: true)
        let releasedView = makeInfoColumn(title: "Released", main: "2014", subtitle: "31 December")
        let languageView = makeInfoColumn(title: "Language", main: "EN",   subtitle: "English")
        let lengthView   = makeInfoColumn(title: "Length", main: "218",  subtitle: "Pages", divider: false)

        otherInfoStack.addArrangedSubview(genreView)
        otherInfoStack.addArrangedSubview(releasedView)
        otherInfoStack.addArrangedSubview(languageView)
        otherInfoStack.addArrangedSubview(lengthView)
    }

    func makeInfoColumn(title: String, main: String, subtitle: String?,divider: Bool = true,icon: Bool = false) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(v)

        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            v.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            v.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            v.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])

        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        titleLabel.textColor = AppColors.subtitle
        v.addArrangedSubview(titleLabel)

        
        if !icon {
            let mainLabel = UILabel()
            mainLabel.text = main
            mainLabel.font = .systemFont(ofSize: 20, weight: .bold)
            mainLabel.textColor = .label
            v.addArrangedSubview(mainLabel)
        }
        else {
            let imageView = UIImageView(image: UIImage(systemName: "book.fill"))
            imageView.tintColor = .label
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 32),
                imageView.widthAnchor.constraint(equalToConstant: 32)
            ])
            v.addArrangedSubview(imageView)
        }



        if let subtitle = subtitle {
            let sub = UILabel()
            sub.text = subtitle
            sub.font = .systemFont(ofSize: 10)
            sub.textColor = .label
            v.addArrangedSubview(sub)
        }

        if divider {
            let divider = UIView()
            divider.backgroundColor = .systemGray3
            divider.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.widthAnchor.constraint(equalToConstant: 1),
                divider.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
                divider.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
                divider.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])}

        return container
    }

    func makeVerticalSeparator(color: UIColor = .white,
                               inset: CGFloat = 0) -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false
        let lineHeight = 1 / UIScreen.main.scale
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: lineHeight)
        ])
        return lineView
    }
    
    @objc func reviewsSeeallButtonTapped() {
        let reviewsVC = ReviewViewController(book: book)
        if let nav = navigationController {
            nav.pushViewController(reviewsVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: reviewsVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
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

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        getReadButton.layer.cornerRadius = getReadButton.bounds.height / 2
//        getReadButton.layer.masksToBounds = true
//    }
}
