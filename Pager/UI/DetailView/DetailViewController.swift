//
//  DetailViewController.swift
//  Pager
//
//  Created by Pradheep G on 26/11/25.
//

import UIKit

class DetailViewController: UIViewController {
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
//    private let reviewCollectionView: UICollectionView = UICollectionView()
    private let reviewCollectionView: UICollectionView
    private let book: Book
    
    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        setUpStackView()
        setUpContent()
    }
    
    func setUpScrollView() {
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
        mainStackView.addArrangedSubview(otherInfoStack)
        let verticalSeparator3 = makeVerticalSeparator()
        mainStackView.addArrangedSubview(verticalSeparator3)
        mainStackView.addArrangedSubview(<#T##view: UIView##UIView#>)
        
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
            
        ])
    }
    
    func setUpOtherInfoStack() {
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

        // right divider
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

    func makeVerticalSeparator(color: UIColor = .systemGray4,
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
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        getReadButton.layer.cornerRadius = getReadButton.bounds.height / 2
//        getReadButton.layer.masksToBounds = true
//    }
}
