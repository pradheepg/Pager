//
//  DetailViewController.swift
//  Pager
//
//  Created by Pradheep G on 26/11/25.
//

import UIKit
internal import CoreData

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

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
    private let moreButton: UIButton = UIButton(type: .system)
    private let averageRatingLabel: UILabel = UILabel()
    private let starStack: UIStackView = UIStackView()
    private let totalRatingLabel: UILabel = UILabel()
//    private var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    private let readMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("More", for: .normal)
        btn.setTitleColor(AppColors.title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    var onDismiss: (() -> Void)?
    private var isOwned: Bool = false {
        didSet {
            updateButtonUI()
        }
    }
    
    private let starButtonStack: UIStackView = UIStackView()
    private let viewModel: DetailViewModel
    
    
    init(book: Book) {
        self.viewModel = DetailViewModel(book: book)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.itemSize = CGSize(width: 350, height: 150)
        reviewCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        if let records = UserSession.shared.currentUser?.owned?.allObjects as? [UserBookRecord] {
            if records.contains(where: { $0.book == book }) {
                isOwned = true
            }
        }
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.book.title
        view.backgroundColor = AppColors.gridViewBGColor

        navigationItem.titleView = UIView()
        //        loadSameData()
        viewModel.loadData()
        setUpScrollView()
        setUpStackView()
        setUpContent()
        setupMoreMenu()
        updateButtonUI()
        setupCloseButton()
//        setupPullToDismiss()
        if let existingReview = viewModel.getCurrentUserReview() {
            let savedRating = Int(existingReview.rating)
            updateStarUI(rating: savedRating)
        }
        
    }
    
//    private func setupPullToDismiss() {
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan(_:)))
//        panGesture.delegate = self
//        view.addGestureRecognizer(panGesture)
//    }
//
//    @objc func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
//        print("Handel this is called")
//        let translation = gesture.translation(in: view)
//        let isVertical = abs(translation.y) > abs(translation.x)
//        
//        switch gesture.state {
//        case .began:
//            initialTouchPoint = gesture.location(in: view)
//        case .changed:
//            guard translation.y > 0 && isVertical else { return }
//            
//            view.transform = CGAffineTransform(translationX: 0, y: translation.y)
//            view.alpha = 1.0 - min(translation.y / 800, 0.5)
//            
//        case .ended, .cancelled:
//            if translation.y > 150 {
//                onDismiss?()
//                dismiss(animated: true, completion: nil)
//            } else {
//                UIView.animate(withDuration: 0.3) {
//                    self.view.transform = .identity
//                    self.view.alpha = 1.0
//                }
//            }
//        default:
//            break
//        }
//    }
    
    func updateButtonUI() {
        if isOwned {
            getReadButton.setTitle("READ", for: .normal)
            
            ratingStackView.alpha = 1.0
            ratingStackView.isUserInteractionEnabled = true
            setupMoreMenu()
            
            
        } else {
            getReadButton.setTitle("GET", for: .normal)
            ratingStackView.alpha = 0.3
            ratingStackView.isUserInteractionEnabled = true
            setupMoreMenu()
        }
    }
    
    private func setUpScrollView() {

        
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainScrollView)
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
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
        reviewCollectionView.isPagingEnabled = true
        reviewCollectionView.register(ReviewCell.self, forCellWithReuseIdentifier: "ReviewCell")
        //        reviewCollectionView.register(DemoCell.self, forCellWithReuseIdentifier: "DemoCell")
        
        
        
    }
    
    func setUpContent() {
        mainStackView.addArrangedSubview(coverImageView)
        mainStackView.addArrangedSubview(bookNameLable)
        mainStackView.addArrangedSubview(authorNameLable)
        //        mainStackView.addArrangedSubview(getReadButton)
        let verticalSeparator1 = makeVerticalSeparator()
        mainStackView.addArrangedSubview(verticalSeparator1)
        mainStackView.addArrangedSubview(descriptionView)
        let verticalSeparator2 = makeVerticalSeparator()
        mainStackView.addArrangedSubview(verticalSeparator2)
        
        
        
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.backgroundColor = AppColors.gridViewBGColor
        coverImage.contentMode = .scaleToFill
        coverImage.layer.masksToBounds = true
        coverImage.image = ViewHelper.getCoverImage(of: viewModel.book)
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.addSubview(coverImage)
        
        bookNameLable.text = viewModel.book.title
        bookNameLable.textAlignment = .center
        bookNameLable.font = UIFont.boldSystemFont(ofSize: 28)
        bookNameLable.numberOfLines = 0
        bookNameLable.translatesAutoresizingMaskIntoConstraints = false
        
        authorNameLable.text = viewModel.book.author
        authorNameLable.textAlignment = .center
        authorNameLable.font = UIFont.systemFont(ofSize: 20)
        authorNameLable.numberOfLines = 0
        authorNameLable.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStack = UIStackView()
        mainStackView.addArrangedSubview(buttonStack)
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fill
        buttonStack.alignment = .fill
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        getReadButton.setTitle("GET", for: .normal)
        getReadButton.setTitleColor(AppColors.background, for: .normal)
        getReadButton.backgroundColor = AppColors.title
        getReadButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        getReadButton.translatesAutoresizingMaskIntoConstraints = false
        getReadButton.layer.cornerRadius = 24
        getReadButton.layer.masksToBounds = true
        getReadButton.addTarget(self, action: #selector(getReadButtonTapped), for: .touchUpInside)
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        moreButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        moreButton.tintColor = AppColors.title
        moreButton.backgroundColor = AppColors.gridViewSecondaryColor
        moreButton.layer.cornerRadius = 25
        moreButton.layer.masksToBounds = true
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        buttonStack.addArrangedSubview(getReadButton)
        buttonStack.addArrangedSubview(moreButton)
        
        
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.backgroundColor = AppColors.gridViewBGColor
        
        descriptionTitleLable.text = "Publisher Description"
        descriptionTitleLable.textAlignment = .left
        descriptionTitleLable.font = UIFont.boldSystemFont(ofSize: 17)
        descriptionTitleLable.numberOfLines = 0
        descriptionTitleLable.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.addSubview(descriptionTitleLable)
        
        descriptionContentLable.text = viewModel.book.descriptionText
        descriptionContentLable.textAlignment = .left
        descriptionContentLable.font = UIFont.systemFont(ofSize: 16)
        descriptionContentLable.numberOfLines = 4
        descriptionContentLable.translatesAutoresizingMaskIntoConstraints = false
        let tapGestore = UITapGestureRecognizer(target: self, action: #selector(toggleDescription))
        descriptionView.addGestureRecognizer(tapGestore)
        descriptionView.addSubview(descriptionContentLable)
        
        descriptionView.addSubview(readMoreButton)
        readMoreButton.addTarget(self, action: #selector(toggleDescription), for: .allTouchEvents)

        if (descriptionContentLable.text?.count ?? 0) < 150 {
            readMoreButton.isHidden = true
            descriptionContentLable.numberOfLines = 0
        }
        
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
            
            getReadButton.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.7),
            getReadButton.heightAnchor.constraint(equalToConstant: 50),
            moreButton.widthAnchor.constraint(equalTo: buttonStack.heightAnchor),
            
            verticalSeparator1.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            verticalSeparator1.heightAnchor.constraint(lessThanOrEqualToConstant: 50),

            
            descriptionTitleLable.topAnchor.constraint(equalTo: descriptionView.topAnchor),
            descriptionTitleLable.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor),
            descriptionTitleLable.bottomAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 20),
            
            descriptionContentLable.topAnchor.constraint(equalTo: descriptionTitleLable.bottomAnchor),
            descriptionContentLable.leadingAnchor.constraint(equalTo: descriptionTitleLable.leadingAnchor),
            descriptionContentLable.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -10),
            descriptionContentLable.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor),
            
            readMoreButton.topAnchor.constraint(equalTo: descriptionContentLable.bottomAnchor, constant: 5),
            readMoreButton.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor),
            readMoreButton.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor),
            
            descriptionView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.9),
            descriptionView.heightAnchor.constraint(lessThanOrEqualToConstant: 2000),
            
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
    
    
    @objc func getReadButtonTapped() {
        if isOwned {
            let vc = MainBookReaderViewController(book: viewModel.book)
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
            }
        } else {
            switch viewModel.purchaseBook(viewModel.book) {
            case .success(let success):
                Haptics.shared.notify(.success)
                self.isOwned = true
                
                let alert = UIAlertController(
                    title: "Book Added Successfully!",
                    message: "Would you like to open this book now?",
                    preferredStyle: .alert
                )
                
                let cancelAction = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
                
                let openAction = UIAlertAction(title: "Read Now", style: .default) { [weak self] _ in
                    
                    self?.getReadButtonTapped()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(openAction)
                
                present(alert, animated: true)
            case .failure(let failure):
                let alert = UIAlertController(
                    title: "Purchase Failed",
                    message: "We couldn't add this book to your library.\nError: \(failure.localizedDescription)",
                    preferredStyle: .alert
                )
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed {
            onDismiss?()
        }
    }
    
    //    private func setupMoreMenu() {
    //        let collectionsMenu = UIDeferredMenuElement.uncached { [weak self] completion in
    //            guard let self = self else { return }
    //
    //            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
    //
    //            let collectionItems = allCollections.map { collection in
    //                UIAction(title: collection.name ?? "Untitled", image: UIImage(systemName: "folder")) { action in
    //                    switch self.viewModel.addBook(self.viewModel.book, to: collection) {
    //                    case .success():
    //                        print("Adding to \(collection.name ?? "")")
    //                    case .failure(let error):
    //                        print(error.localizedDescription)
    //                    }
    //                }
    //            }
    //
    //            let createNewAction = UIAction(title: "New Collection...", image: UIImage(systemName: "plus")) { action in
    //                print("Create new collection tapped")
    //                // self.showCreateCollectionAlert()
    //            }
    //
    //            let menu = UIMenu(title: "Add to Collection", image: UIImage(systemName: "folder.badge.plus"), children: collectionItems )//+ [createNewAction])
    //
    //            // Pass back to the system
    //            completion([menu])
    //        }
    //
    //        let reviewAction = UIAction(title: "View Reviews", image: UIImage(systemName: "bubble.and.pencil")) { [weak self] _ in
    //            self?.reviewsSeeallButtonTapped()
    //        }
    //
    //        let wantToReadAction = UIAction(title: "Want to Read", image: UIImage(systemName: "bookmark")) { _ in
    //            print("Want to read tapped")
    //        }
    //
    //        let removeAction = UIAction(title: "Remove book", image: UIImage(systemName: "minus.circle.fill"), attributes: .destructive) { _ in
    //            print("Report tapped")
    //        }
    //
    //
    //        let menu = UIMenu(title: "Options", children: [
    //            UIMenu(options: .displayInline, children: [wantToReadAction, reviewAction]),
    //            collectionsMenu, // This is our dynamic list
    //            UIMenu(options: .displayInline, children: [removeAction])
    //        ])
    //
    //        moreButton.menu = menu
    //        moreButton.showsMenuAsPrimaryAction = true
    //    }
    
    private func setupMoreMenu() {
        moreButton.menu = makeContextMenu(for: viewModel.book)
        moreButton.showsMenuAsPrimaryAction = true
    }

    func makeContextMenu(for book: Book) -> UIMenu {
        let isWantToRead = viewModel.isBookInDefaultCollection(book, name: DefaultsName.wantToRead)
        
        let wantToReadAction = UIAction(
            title: DefaultsName.wantToRead,
            image: UIImage(systemName: isWantToRead ? "bookmark.fill" : "bookmark")
        ) { [weak self] _ in
            guard let self = self else { return }
            let result = self.viewModel.toggleDefaultCollection(book: book, collectionName: DefaultsName.wantToRead)
            self.showToast(result: result, collectionName: DefaultsName.wantToRead, isAdded: !isWantToRead)
            self.setupMoreMenu()
        }
        
        let reviewAction = UIAction(title: "View Reviews", image: UIImage(systemName: "text.bubble")) { [weak self] _ in
            self?.reviewsSeeallButtonTapped()
        }
        
        var menuItems: [UIMenuElement] = [
            UIMenu(options: .displayInline, children: [reviewAction, wantToReadAction]),
            
        ]
        if isOwned {
            let isFinished = viewModel.isBookInDefaultCollection(book, name: DefaultsName.finiahed)
            let finishedAction = UIAction(
                title: isFinished ? "Mark as Unread" : "Mark as Completed",
                image: UIImage(systemName: isFinished ? "checkmark.circle.fill" : "checkmark.circle")
            ) { [weak self] _ in
                guard let self = self else { return }
                let result = self.viewModel.toggleDefaultCollection(book: book, collectionName: DefaultsName.finiahed)
                self.showToast(result: result, collectionName: DefaultsName.finiahed, isAdded: !isFinished)
                self.setupMoreMenu()
                
            }
            menuItems.append(UIMenu(options: .displayInline, children: [finishedAction]))

        }
        
        let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
        
        let containingCollectionIDs = (book.collections as? Set<BookCollection>)?.map { $0.objectID } ?? []
        let containingSet = Set(containingCollectionIDs)
        let customCollections = allCollections
            .filter { $0.isDefault == false }
            .sorted {
                ($0.createdAt ?? Date.distantPast) < ($1.createdAt ?? Date.distantPast)
            }
        var customCollectionActions = customCollections
            .map { collection in
                let isPresent = containingSet.contains(collection.objectID)
                let collectionName = collection.name ?? "Untitled"
                
                return UIAction(
                    title: collectionName,
                    image: UIImage(systemName: isPresent ? "folder.fill" : "folder")
                ) { [weak self] _ in
                    guard let self = self else { return }
                    
                    if isPresent {
                        let result = self.viewModel.deleteFromCollection(collection: collection, book: book)
                        self.showToast(result: result, collectionName: collectionName, isAdded: false)
                    } else {
                        let result = self.viewModel.addBook(book, to: collection)
                        self.showToast(result: result, collectionName: collectionName, isAdded: true)
                    }
                    self.setupMoreMenu()
                }
            }
        
        let addCollection = UIAction(title: "Add New", image: UIImage(systemName: "plus")) {  _ in
            self.showAddItemAlert(book: book)
        }
        
        customCollectionActions.append(addCollection)
        
        let addToCollectionMenu = UIMenu(
            title: "Add to Collection",
            image: UIImage(systemName: "folder.badge.plus"),
            children: customCollectionActions
        )
        menuItems.append(UIMenu(options: .displayInline, children: [setUpAddToCollectionView(book: book)]))
        
        
        
        if isOwned {
            let removeAction = UIAction(
                title: "Remove from Library",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                guard let self = self else { return }
                
                let result = self.viewModel.unpurchaseBook(book)
                
                switch result {
                case .success:
                    Toast.show(message: "Removed from Library", icon: "trash", in: self.view)
                    Haptics.shared.notify(.success)
                    self.isOwned = false
                    
                case .failure(let error):
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
            
            menuItems.append(UIMenu(options: .displayInline, children: [removeAction]))
        }

        return UIMenu(title: "", children: menuItems)
    }
    
    func setUpAddToCollectionView(book: Book) -> UIAction {
        return UIAction(title: "Add to Collection",
                                           image: UIImage(systemName: "folder.badge.plus")) { [weak self] _ in
            guard let self = self else { return }
            let addToCollectionVC = AddToCollectionViewController(book: book)
            addToCollectionVC.onDismiss = { [weak self] in
                print("OnDismiss")
                self?.setupMoreMenu()
            }
            let nav = UINavigationController(rootViewController: addToCollectionVC)
            
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                
                sheet.prefersGrabberVisible = true
                
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            }
            
            self.present(nav, animated: true)
        }
        
    }
    
    func showAddItemAlert(book: Book) {
        let alertController = UIAlertController(
            title: "Add New Collection",
            message: "Enter the name for the new Collection.",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Collection name"
            textField.delegate = self
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alertController.textFields?.first?.text,
                  !text.isEmpty else {
                return
            }
            
            self.addNewItem(name: text, book: book)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    func addNewItem(name: String, book: Book) {
        guard let _ = UserSession.shared.currentUser else { return }
        
        let result = viewModel.addNewCollection(as: name)
        
        switch result {
        case .success(let newCollection):
            
            switch viewModel.addBook(book, to: newCollection) {
            case .success(_):
                Toast.show(message: "Collection created and book added successfully ", in: self.view)
                self.setupMoreMenu()
            case .failure(let error):
                print("error: \(error)")

            }

        case .failure(let error):
            
            if case .alreadyExists = error as? CollectionError {
                showNameExistsAlert(name: name)
            } else {
                print("Generic creation error: \(error)")
            }
        }
    }
    
    func showNameExistsAlert(name: String) {
        let alertController = UIAlertController(
            title: "Collection Already Exists!",
            message: "The Collection '\(name)' is already in your list. Please enter a different collection name.",
            preferredStyle: .alert
        )
        
        let dismissAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showToast(result: Result<Void,CollectionError>?, collectionName: String?, isAdded: Bool) {
        guard let result = result, let collectionName = collectionName else {
            return
        }
        switch result {
        case .success():
            Toast.show(message: "\(isAdded ? "Added to ":"Removed from ") \(collectionName)", in: self.view)
        case .failure(let error):
            print(error)
        }
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
            starButton.setImage(UIImage(systemName: "star.fill", withConfiguration: largeConfig), for: .highlighted)
            starButton.setImage(UIImage(systemName: "star.fill", withConfiguration: largeConfig), for: [.selected, .highlighted])
            
            starButton.tintColor = AppColors.systemBlue
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
        seeAllButton.setTitleColor(AppColors.systemBlue, for: .normal)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        let summaryRowStackView: UIStackView = UIStackView()
        rootStackView.addArrangedSubview(summaryRowStackView)
        summaryRowStackView.axis = .horizontal
        summaryRowStackView.distribution = .equalSpacing
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
                starIcon.tintColor = .lightGray
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
    
    func setUpOtherInfoStack() {
        mainStackView.addArrangedSubview(otherInfoStack)
        otherInfoStack.axis = .horizontal
        otherInfoStack.distribution = .fillProportionally
        otherInfoStack.alignment = .fill
        otherInfoStack.spacing = 0
        otherInfoStack.translatesAutoresizingMaskIntoConstraints = false
        
        let genreEnum = getCategoryEnum(from: viewModel.book.genre)
        let genreView = makeInfoColumn(title: "Genre",
                                       main: "",
                                       subtitle: genreEnum.rawValue,
                                       icon: true, genre: genreEnum)
        
        let dateData = getReleasedDateStrings()
        let releasedView = makeInfoColumn(title: "Released",
                                          main: dateData.year,
                                          subtitle: dateData.date)
        
        let langData = getLanguageStrings()
        let languageView = makeInfoColumn(title: "Language",
                                          main: langData.code,
                                          subtitle: langData.name)
        
        let stats = getReadingStats()
        
//        let lengthView = makeInfoColumn(title: "Length",
//                                        main: stats.pages,
//                                        subtitle: "Pages",
//                                        divider: true)
        
        let readingTimeView = makeInfoColumn(title: "Reading time",
                                             main: stats.timeMain,
                                             subtitle: stats.timeSub,
                                             divider: false)
        
        otherInfoStack.addArrangedSubview(genreView)
        otherInfoStack.addArrangedSubview(releasedView)
        otherInfoStack.addArrangedSubview(languageView)
        //        otherInfoStack.addArrangedSubview(lengthView)
        otherInfoStack.addArrangedSubview(readingTimeView)
    }
    
    func getReleasedDateStrings() -> (year: String, date: String) {
        guard let date = viewModel.book.publicationDate else { return ("-", "-") }
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        let dayMonthFormatter = DateFormatter()
        dayMonthFormatter.dateFormat = "d MMMM"
        
        return (yearFormatter.string(from: date), dayMonthFormatter.string(from: date))
    }
    
    func getLanguageStrings() -> (code: String, name: String) {
        let code = viewModel.book.language ?? "en"
        let name = Locale.current.localizedString(forLanguageCode: code) ?? "Unknown"
        return (code.uppercased(), name.capitalized)
    }
    
    func getReadingStats() -> (pages: String, timeMain: String, timeSub: String) {
        guard let fileName = viewModel.book.contentText,
              !fileName.isEmpty else {
            return ("-", "-", "-")
        }
        
        let fullText = ViewHelper.loadBookContent(fileName: viewModel.book.contentText ?? "")
        let charCount = fullText.count
        if charCount == 0 { return ("0", "0", "Min") }
        
        let pages = max(1, charCount / 1500)
        
        let totalMinutes = max(1, charCount / 1000)
        if totalMinutes < 60 {
            return ("\(pages)", "\(totalMinutes)", "Min")
        } else {
            let hours = totalMinutes / 60
            return ("\(pages)", "\(hours)", "Hours")
        }
    }
    
    func getCategoryEnum(from genreString: String?) -> CategoryEnum {
        guard let rawString = genreString?.lowercased() else {
            return .novels // Default fallback
        }
        
        if rawString.contains("thriller") || rawString.contains("mystery") ||
           rawString.contains("horror")   || rawString.contains("crime") ||
           rawString.contains("gothic") {
            return .thriller
        }
        
        if rawString.contains("fantasy") || rawString.contains("sci-fi") ||
           rawString.contains("science") || rawString.contains("magic") {
            return .fantasy
        }
        
        if rawString.contains("biography") || rawString.contains("memoir") ||
           rawString.contains("autobiography") {
            return .biography
        }
        
        if rawString.contains("business") || rawString.contains("finance") ||
           rawString.contains("economics") || rawString.contains("money") {
            return .business
        }
        
        if rawString.contains("kid") || rawString.contains("children") ||
           rawString.contains("juvenile") {
            return .kids
        }
        
        return .novels
    }
    
    func makeInfoColumn(title: String, main: String, subtitle: String?,divider: Bool = true,icon: Bool = false, genre: CategoryEnum = .thriller) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.distribution = .equalSpacing
        v.spacing = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(v)
        
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            v.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            v.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            v.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        titleLabel.textColor = AppColors.subtitle
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        v.addArrangedSubview(titleLabel)
        
        
        if !icon {
            let mainLabel = UILabel()
            mainLabel.text = main
            mainLabel.font = .systemFont(ofSize: 20, weight: .bold)
            mainLabel.textColor = .label
            mainLabel.adjustsFontSizeToFitWidth = true
            mainLabel.minimumScaleFactor = 0.5
            mainLabel.numberOfLines = 1
            v.addArrangedSubview(mainLabel)
        }
        else {
            let imageView = UIImageView(image: UIImage(systemName: genre.systemImageName))
            imageView.tintColor = .label
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let hConst = imageView.heightAnchor.constraint(equalToConstant: 32)
            let wConst = imageView.widthAnchor.constraint(equalToConstant: 32)
            hConst.priority = .defaultHigh
            wConst.priority = .defaultHigh
            
            NSLayoutConstraint.activate([hConst, wConst])
            v.addArrangedSubview(imageView)
        }
        
        
        
        if let subtitle = subtitle {
            let sub = UILabel()
            sub.text = subtitle
            sub.font = .systemFont(ofSize: 10)
            sub.textColor = .label
            sub.adjustsFontSizeToFitWidth = true
            v.addArrangedSubview(sub)
        }
        
        if divider {
            let divider = UIView()
            divider.backgroundColor = AppColors.separatorColor
            divider.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.widthAnchor.constraint(equalToConstant: 0.8),
                divider.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
                divider.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
                divider.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])}
        
        return container
    }
    
    private func setupCloseButton() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))

        closeButton.tintColor = AppColors.title
        
//        navigationItem.rightBarButtonItem = closeButton
         navigationItem.leftBarButtonItem = closeButton
    }

    @objc private func didTapClose() {
        onDismiss?()
        dismiss(animated: true, completion: nil)
    }
    
    func makeVerticalSeparator(color: UIColor = AppColors.separatorColor,
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
        let reviewsVC = ReviewViewController(book: viewModel.book)
        if let nav = navigationController {
            nav.pushViewController(reviewsVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: reviewsVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    @objc func starTapped(_ sender: UIButton) {
        
        if !isOwned {
            let alert = UIAlertController(
                title: "Purchase Required",
                message: "You need to purchase this book before you can rate it.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alert, animated: true)
            Haptics.shared.notify(.error)
            return
        }
        updateTotalRatingText()
        let selectedRating = sender.tag
        let result = viewModel.submitReview(rating: selectedRating)
        switch result {
        case .success:
            updateStarUI(rating: selectedRating)
            refreshHeaderUI()
            reviewCollectionView.reloadData()
            Haptics.shared.play(.light)
            Toast.show(message: "Rating Added", in: self.view)
            
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
        totalRatingLabel.text = "\(viewModel.totalReviews) Ratings"
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
    
    @objc func toggleDescription() {
        descriptionContentLable.numberOfLines = 0
        readMoreButton.isHidden = true
        descriptionContentLable.gestureRecognizers?.first?.isEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ViewReviewViewController(review: viewModel.reviews[indexPath.item])
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        cell.configure(with: viewModel.reviews[indexPath.item])
        return cell
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= ContentLimits.collectionMaxNameLength
    }
    
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //        getReadButton.layer.cornerRadius = getReadButton.bounds.height / 2
    //        getReadButton.layer.masksToBounds = true
    //    }
}
