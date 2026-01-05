//
//  MyBooksViewController.swift
//  Pager
//
//  Created by Pradheep G on 01/12/25.
//
import UIKit
import CoreData

enum BookSortOption: String, CaseIterable {
    case lastOpened = "Last Opened"
    case title = "Title"
    case author = "Author"
    case dateAdded = "Date Added"
    
    var displayTitle: String {
        return self.rawValue
    }
}

enum SortOrder: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
    
    var displayTitle: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .ascending: return "chart.bar.xaxis.ascending"
        case .descending: return "chart.bar.xaxis.descending"
        }
    }
}

class MyBooksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    let viewModel: MyBooksViewModel
    private let collectionView: UICollectionView
    private let sortLable: UILabel = {
        let label = UILabel()
        label.text = "Sort"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var didFinishTask: (() -> Void)?
    private let sortStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private lazy var sortButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = viewModel.currentSortOption.displayTitle
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        
        config.baseForegroundColor = .label
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            return outgoing
        }
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = false
        
        return button
    }()
    
//    private var currentSortTitle: BookSortOption = .lastOpened
//    private var isAscending: SortOrder = .ascending
    
    init(books: [Book]) {
        self.viewModel = MyBooksViewModel(books: books)
        let layout = MyBooksViewController.createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupSortStackLayout()//setupSortStack()
        setUpCollectionView()
        
        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()

        }
    }
    
    func update(books: [Book]) {
        viewModel.books = books
        collectionView.reloadData()
        viewModel.applySort()
    }

    func handleSortChange(sortOption: BookSortOption) {
        viewModel.didSelectSortOption(sortOption)
//        currentSortTitle = sortOption
        var config = sortButton.configuration
        
        config?.title = sortOption.displayTitle
        
        sortButton.configuration = config
        updateSortButtonMenu()// setupSortStack()
    }
    
    func handleOrderChange(sortOrder: SortOrder) {
//        isAscending = sortOrder
        viewModel.didSelectSortOrder(sortOrder)
        updateSortButtonMenu()//setupSortStack()

    }
    
    
    func setupSortStackLayout() {
        sortStack.addArrangedSubview(sortLable)
        sortStack.addArrangedSubview(sortButton)
        view.addSubview(sortStack)
        
        NSLayoutConstraint.activate([
            sortStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sortStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
        
        updateSortButtonMenu()
    }
    
    func updateSortButtonMenu() {
        var config = sortButton.configuration
        config?.title = viewModel.currentSortOption.displayTitle
        sortButton.configuration = config
        
        let sortOption = viewModel.currentSortOption
        
        let lastOpened = UIAction(title: BookSortOption.lastOpened.displayTitle, state: sortOption == .lastOpened ? .on : .off) { [weak self] _ in
            self?.handleSortChange(sortOption: .lastOpened)
        }
        let title = UIAction(title: BookSortOption.title.displayTitle, state: sortOption == .title ? .on : .off) { [weak self] _ in
            self?.handleSortChange(sortOption: .title)
        }
        let author = UIAction(title: BookSortOption.author.displayTitle, state: sortOption == .author ? .on : .off) { [weak self] _ in
            self?.handleSortChange(sortOption: .author)
        }
        let dateAdded = UIAction(title: BookSortOption.dateAdded.displayTitle, state: sortOption == .dateAdded ? .on : .off) { [weak self] _ in
            self?.handleSortChange(sortOption: .dateAdded)
        }
        
        let sortSection = UIMenu(title: "Sort By", options: .displayInline, children: [lastOpened, title, author, dateAdded])
        
        let sortOrder = viewModel.currentSortOrder
        let ascending = UIAction(title: SortOrder.ascending.displayTitle, image: UIImage(systemName: SortOrder.ascending.iconName), state: sortOrder == .ascending ? .on : .off) { [weak self] _ in
            self?.handleOrderChange(sortOrder: .ascending)
        }
        let descending = UIAction(title: SortOrder.descending.displayTitle, image: UIImage(systemName: SortOrder.descending.iconName), state: sortOrder == .descending ? .on : .off) { [weak self] _ in
            self?.handleOrderChange(sortOrder: .descending)
        }
        let viewSection = UIMenu(title: "Order", options: .displayInline, children: [ascending, descending])
        let actions = [lastOpened, title, author, dateAdded, ascending, descending]
        actions.forEach { $0.attributes = .keepsMenuPresented }
        sortButton.menu = UIMenu(title: "", children: [sortSection, viewSection])
    }
    
    
    private static func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        section.interGroupSpacing = 15
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setUpCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = AppColors.background
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: sortStack.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
        //        cell.contentView.backgroundColor = AppColors.secondaryBackground
        cell.configure(with: viewModel.books[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = viewModel.books[indexPath.item]
        let vc = DetailViewController(book: book)
        vc.onDismiss = { [weak self] in
            self?.didFinishTask?()
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let book = viewModel.books[indexPath.item] // Get the book
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return self.makeContextMenu(for: book)
        }
    }
    
    func makeContextMenu(for book: Book) -> UIMenu {
        
        let detailsAction = UIAction(title: "View Details", image: UIImage(systemName: "info.circle")) { [weak self] _ in
            let vc = DetailViewController(book: book)
            vc.onDismiss = { [weak self] in
                self?.didFinishTask?()
            }
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true)
        }
        
        let isWantToRead = viewModel.isBookInDefaultCollection(book, name: DefaultsName.wantToRead)
        
        let wantToReadAction = UIAction(
            title: DefaultsName.wantToRead,
            image: UIImage(systemName: isWantToRead ? "bookmark.fill" : "bookmark"),
            attributes: []//isWantToRead ? .destructive : []
        ) { [weak self] _ in
            self?.showToast(result: self?.viewModel.toggleDefaultCollection(book: book, collectionName: DefaultsName.wantToRead), collectionName: DefaultsName.wantToRead, isAdded: !isWantToRead)
        }

        let isFinished = viewModel.isBookInDefaultCollection(book, name: DefaultsName.finiahed)
        
        let finishedAction = UIAction(
            title: isFinished ? "Mark as Unread" : "Mark as Completed",
            image: UIImage(systemName: isFinished ? "checkmark.circle.fill" : "checkmark.circle"),
            attributes: []
        ) { [weak self] _ in
            self?.showToast(result: self?.viewModel.toggleDefaultCollection(book: book, collectionName: DefaultsName.finiahed), collectionName: DefaultsName.finiahed, isAdded: !isFinished)
        }

        let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
        let customCollections = allCollections
            .filter { $0.isDefault == false }
            .sorted {
                ($0.createdAt ?? Date.distantPast) < ($1.createdAt ?? Date.distantPast)
            }
        let containingCollectionIDs = (book.collections as? Set<BookCollection>)?.map { $0.objectID } ?? []
        let containingSet = Set(containingCollectionIDs)

        var customCollectionActions = customCollections
            .map { collection in
                let isPresent = containingSet.contains(collection.objectID)
                
                return UIAction(
                    title: collection.name ?? "Untitled",
                    image: UIImage(systemName: isPresent ? "folder.fill" : "folder"),
//                    attributes: .keepsMenuPresented
                ) { [weak self] _ in
                    if isPresent {
                        self?.showToast(result: self?.viewModel.deleteFromCollection(collection: collection, book: book), collectionName: collection.name, isAdded: false)
                    } else {
                        self?.showToast(result: self?.viewModel.addToCollection(collection: collection, book: book), collectionName: collection.name, isAdded: true)
                    }
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

        let removeAction = UIAction(
            title: "Remove",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            let result = self?.viewModel.unpurchaseBook(book)
            switch result {
            case .success():
                if let self = self {
                    Haptics.shared.notify(.success)
                    Toast.show(message: "Book Removed from Library ", in: view)
                }
                self?.didFinishTask?()

                self?.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            case .none:
                print("Non AS responce!!")
            }
        }

        return UIMenu(
            title: "",
            children: [
                detailsAction,
                UIMenu(options: .displayInline, children: [wantToReadAction, finishedAction]),
                addToCollectionMenu,
                UIMenu(options: .displayInline, children: [removeAction])
            ]
        )
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
            
            switch viewModel.addToCollection(collection: newCollection, book: book) {
            case .success(_):
                Toast.show(message: "Collection created and book added successfully ", in: self.view)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= ContentLimits.collectionMaxNameLength
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
