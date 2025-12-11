//
//  SearchViewController.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//
import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
        
    private var tagsCollectionView: UICollectionView!
    private var resultsCollectionView: UICollectionView!
    
    var collapsedSections = Set<Int>()
    let tagsTitleLabel = UILabel()

    private var myBooks: [Book] = []
    private var books: [Book] = []
    
    private let bookRepository = BookRepository()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // Empty State
    private let emptyStateView: EmptyMyBooksViewController = EmptyMyBooksViewController(message: "No Result Found!", isButtonNeeded: false)
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setUpEmptyState()
        setUpTagsCollectionView()    // Setup View 1
        setUpResultsCollectionView() // Setup View 2
        setUpSearchController()
    }
    
    // MARK: - UI Setup
    
    private func setUpEmptyState() {
        addChild(emptyStateView)
        view.addSubview(emptyStateView.view)
        emptyStateView.didMove(toParent: self)
        
        emptyStateView.view.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.view.isHidden = true // Hidden by default
        
        NSLayoutConstraint.activate([
            emptyStateView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // Setup 1: The Tags (Recent/Categories) View
    private func setUpTagsCollectionView() {
        // Use your Custom LeftAligned Layout
        let layout = LeftAlignedFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        tagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagsCollectionView.backgroundColor = .systemBackground
        
        // Register Tag Cells
        tagsCollectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
        
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        view.addSubview(tagsTitleLabel)
        tagsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsTitleLabel.text = "Category"
        tagsTitleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        tagsTitleLabel.textColor = AppColors.title
        
        view.addSubview(tagsCollectionView)
        
        NSLayoutConstraint.activate([
            tagsTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tagsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            //            tagsTitleLable.widthAnchor.constraint(equalToConstant: 100),
            tagsTitleLabel.heightAnchor.constraint(equalToConstant: 50),
            tagsCollectionView.topAnchor.constraint(equalTo: tagsTitleLabel.bottomAnchor, constant: 5),
            tagsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setUpResultsCollectionView() {
        let layout = createCompositionalLayout()
        
        
        resultsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        resultsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        resultsCollectionView.backgroundColor = .systemBackground
        resultsCollectionView.isHidden = true // Start HIDDEN
        
        resultsCollectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
        resultsCollectionView.register(
                    CollapsibleCollectionHeader.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: CollapsibleCollectionHeader.reuseID
                )
        
        resultsCollectionView.dataSource = self
        resultsCollectionView.delegate = self
        
        view.addSubview(resultsCollectionView)
        
        NSLayoutConstraint.activate([
            resultsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setUpSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search books, authors..."
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
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
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        // C. (Optional) Sticky Header
         header.pinToVisibleBounds = true
        
        // D. Attach to Section
        section.boundarySupplementaryItems = [header]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func addToken(for category: CategoryEnum) {
        let icon = UIImage(systemName: category.systemImageName) // Use your enum's image
        let token = UISearchToken(icon: icon, text: category.rawValue)
        
        // 2. Assign it to the Search Bar
        // We use direct assignment to replace any existing tokens (Single selection)
        // If you wanted multiple tags, you would use .insertToken(token, at: ...)
        searchController.searchBar.searchTextField.tokens = [token]
        
        // 3. Clear any typed text (so it's just the token)
        searchController.searchBar.text = nil
        
        // 4. Force the search state to active
        searchController.isActive = true
        
        // 5. Manually trigger the update (Changing tokens programmatically doesn't always trigger it)
        updateSearchResults(for: searchController)
    }
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        let tokens = searchController.searchBar.searchTextField.tokens
        
        if searchText.isEmpty && tokens.isEmpty{
            // STATE 1: No Text -> Show Tags
            tagsCollectionView.isHidden = false
            tagsTitleLabel.isHidden = tagsCollectionView.isHidden
            resultsCollectionView.isHidden = true
            emptyStateView.view.isHidden = true
        } else {
            // STATE 2: Typing -> Perform Search
            tagsCollectionView.isHidden = true // Hide tags immediately
            tagsTitleLabel.isHidden = tagsCollectionView.isHidden
            let result = bookRepository.searchBooks(searchText)
            
            switch result {
            case .success(let foundBooks):
                let midpoint = (foundBooks.count + 1) / 2
                self.books = Array(foundBooks[..<midpoint])
                self.myBooks = Array(foundBooks[midpoint...])

                if foundBooks.isEmpty {
                    // STATE 2a: No Results -> Show Empty State
                    resultsCollectionView.isHidden = true
                    emptyStateView.view.isHidden = false
                } else {
                    // STATE 2b: Has Results -> Show Results View
                    resultsCollectionView.isHidden = false
                    emptyStateView.view.isHidden = true
                }
                
                resultsCollectionView.reloadData()
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView  == resultsCollectionView {
            return 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Check WHICH collection view is asking
        if collectionView == tagsCollectionView {
            return CategoryEnum.allCases.count
        } else {
            if collapsedSections.contains(section) {
                return 0
            }
            if section == 0 {
                return myBooks.count
            } else {
                return books.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == tagsCollectionView {
            // Configure Tag Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath) as! CategoryPillCell
            let item = CategoryEnum.allCases[indexPath.item]
            cell.configure(title: item.rawValue, systemImageName: item.systemImageName)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.layer.masksToBounds = true
            if indexPath.section == 0 {
                cell.configure(with: myBooks[indexPath.item])
                
            } else {
                cell.configure(with: books[indexPath.item])
                
            }
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == tagsCollectionView {
            // User tapped a Tag -> Fill Search Bar
            let category = CategoryEnum.allCases[indexPath.item]
            addToken(for: category)
            // This automatically triggers updateSearchResults
            
        } else {
            // User tapped a Result -> Go to Details
            let book = books[indexPath.item]
            let vc = DetailViewController(book: book)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if collectionView == tagsCollectionView {
                return UICollectionReusableView()
            }
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CollapsibleCollectionHeader.reuseID,
                for: indexPath
            ) as? CollapsibleCollectionHeader else {
                return UICollectionReusableView()
            }
            
            let isCollapsed = collapsedSections.contains(indexPath.section)
            let title = indexPath.section == 0 ? "My Books" : "Book Store"
            header.configure(title: title, isCollapsed: isCollapsed)
            
            // 2. Handle the Tap
            header.onToggle = { [weak self] in
                guard let self = self else { return }
                
                // Toggle state
                if self.collapsedSections.contains(indexPath.section) {
                    self.collapsedSections.remove(indexPath.section) // Expand
                } else {
                    self.collapsedSections.insert(indexPath.section) // Collapse
                }
                
                self.resultsCollectionView.reloadSections(IndexSet(integer: indexPath.section))
            }
            
            return header
        }
        return UICollectionReusableView()
    }
}

class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 1. Get the standard attributes from the parent class
        // (This is efficient because it only returns items in the visible rect)
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        // 2. Create a safe copy of the attributes to modify
        // (Modifying the original attributes directly can cause layout warnings)
        var leftAlignedAttributes = [UICollectionViewLayoutAttributes]()
        
        for attribute in attributes {
            if let copy = attribute.copy() as? UICollectionViewLayoutAttributes {
                leftAlignedAttributes.append(copy)
            }
        }
        
        // 3. Loop through and shift items to the left
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        for layoutAttribute in leftAlignedAttributes {
            
            // Check if this cell is on a new row
            // (We check if its Y position is lower than the previous known row)
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left // Reset margin for new row
            }
            
            // Shift the cell to the current left margin
            layoutAttribute.frame.origin.x = leftMargin
            
            // Calculate where the NEXT cell should start
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            
            // Update the vertical tracker
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return leftAlignedAttributes
    }
}

class CollapsibleCollectionHeader: UICollectionReusableView {
    static let reuseID = "CollapsibleCollectionHeader"
    
    // Callback to tell the VC to toggle
    var onToggle: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.up") // Default arrow
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(arrowImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Label on Left
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Arrow on Right
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Add Tap Gesture to the WHOLE header
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTapHeader() {
        onToggle?()
    }
    
    // Helper to update UI state
    func configure(title: String, isCollapsed: Bool) {
        titleLabel.text = title
        
        // Rotate the arrow: Down if collapsed, Up if open
        let angle: CGFloat = isCollapsed ? .pi : 0 // .pi is 180 degrees
        
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}
