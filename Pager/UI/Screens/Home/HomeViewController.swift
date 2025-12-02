//
//  HomeViewController.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import UIKit

enum HomeSection {
    case currently
    case recent
    case wantToRead
    case category(String, [Book])
}

class HomeViewController: UIViewController, UICollectionViewDelegate {
    private let profileButton = UIButton(type: .custom)
    private var collectionView: UICollectionView!
    
    private var currentBook: Book?
    private var recentBooks: [Book] = []
    private var wantToReadBooks: [Book] = []
    private var categories: [(name: String, books: [Book])] = []
    var displayedSections: [HomeSection] {
        var sections: [HomeSection] = [.currently]
        if !recentBooks.isEmpty { sections.append(.recent) }
        if !wantToReadBooks.isEmpty { sections.append(.wantToRead) }
        for category in categories {
            if !category.books.isEmpty {
                sections.append(.category(category.name, category.books))
            }
        }
        return sections
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTitleAndProfile()
        setupCollectionView()
        loadDemoData()
    }
    
    // MARK: - Title & Profile UI
    private func setupTitleAndProfile() {
        // Large Title Label
//        titleLabel.text = "Home"
//        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
//        titleLabel.textAlignment = .left
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
//         Profile Button (circle image)
        profileButton.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        profileButton.tintColor = .label
        profileButton.layer.cornerRadius = 20
        profileButton.layer.masksToBounds = true
//        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        navigationItem.title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 17.0, *) {
            navigationItem.largeTitleDisplayMode = .inline
        }
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
//        view.addSubview(titleLabel)
//        view.addSubview(profileButton)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
//            
//            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            profileButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//            profileButton.widthAnchor.constraint(equalToConstant: 40),
//            profileButton.heightAnchor.constraint(equalToConstant: 40),
//        ])
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
        collectionView.register(CurrentBookCell.self, forCellWithReuseIdentifier: "CurrentBookCell")
        collectionView.register(EmptyCurrentCell.self, forCellWithReuseIdentifier: "EmptyCurrentCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmptyHeader")

        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, environment in
            if section == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                let groupSize : NSCollectionLayoutSize
                if self.currentBook == nil {
                    groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.20))
                } else {
                    groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.35))

                }
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .continuous
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top)
                sectionLayout.boundarySupplementaryItems = [header]
                return sectionLayout
            } else {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.63),
                    heightDimension: .fractionalWidth(0.63 * 1.5)
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .paging
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(40)
                )

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )

                sectionLayout.boundarySupplementaryItems = [header]

                return sectionLayout

            }
        }
    }
    
    private func loadDemoData() {
        let demotemp = BookRepository()
        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
        switch sampleBooks {
        case .success(let books):
            currentBook = books.first
            wantToReadBooks = books
            recentBooks = books
        case .failure(let error):
            print(error.localizedDescription)
            print(error)
        }
        
        
//
//        var defaultCategoryName = "cat 1"
//
//        categories.append((name: defaultCategoryName, books: wantToReadBooks))
//        defaultCategoryName = "cat 2"
//        categories.append((name: defaultCategoryName, books: wantToReadBooks))
//        defaultCategoryName = "cat 3"
//        categories.append((name: defaultCategoryName, books: wantToReadBooks))
//        defaultCategoryName = "cat 4"
//        categories.append((name: defaultCategoryName, books: wantToReadBooks))

        collectionView.reloadData()
  
    }
    
    @objc func profileButtonTapped() {
        print("Profile tapped")
    }
    
    func currentBookMoreTapped() {
        print("Current book menu tapped")
    }
    
    func emptyStateButtonTapped() {
        print("Go to Book Store tapped")
    }
    
    func bookCellTapped(book: Book) {
        let vc = DetailViewController(book: book)
//        self.navigationController?.pushViewController(vc, animated: true)
//        let vc = DetailViewController(book: book)
        present(vc, animated: true, completion: nil)
        print("Book '\(book.title)' tapped")
    }
    
    func seeAllTapped(section: Int,title: String, books: [Book]) {
        let vc = BookGridViewController(categoryTitle: title, books: books)
        self.navigationController?.pushViewController(vc, animated: true)
        print("See All tapped for section \(section)")
        
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displayedSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sec = displayedSections[section]
        switch sec {
        case .currently:
            return 1
        case .recent:
            return recentBooks.count
        case .wantToRead:
            return wantToReadBooks.count
        case .category(_, let books):
            return books.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = displayedSections[indexPath.section]
        switch section {
        case .currently:
            return configureCurrentCell(collectionView, indexPath: indexPath)
        case .recent:
            return configureRecentCell(collectionView, indexPath: indexPath)
        case .wantToRead:
            return configureWantToReadCell(collectionView, indexPath: indexPath)
        case .category(_, let books):
            return configureCategoryCell(collectionView, indexPath: indexPath)
        }
    }
    
    func configureCurrentCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        if let book = currentBook {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentBookCell", for: indexPath) as! CurrentBookCell
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.layer.masksToBounds = true
//            cell.contentView.backgroundColor = AppColors.secondaryBackground
            cell.configure(with: book)
            cell.moreButtonAction = { [weak self] in self?.currentBookMoreTapped() }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCurrentCell", for: indexPath) as! EmptyCurrentCell
            cell.configure(message: "You're not reading, go to Book Store", buttonTitle: "Book Store")
            cell.buttonAction = { [weak self] in self?.emptyStateButtonTapped() }
            return cell
        }
    }
    
    func configureRecentCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        let book = recentBooks[indexPath.item]
        cell.configure(with: book)
        return cell
    }
    
    func configureWantToReadCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        let book = wantToReadBooks[indexPath.item]
        cell.configure(with: book)
        return cell
    }
    
    func configureCategoryCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let catIdx = indexPath.section - 3
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        let book = categories[catIdx].books[indexPath.item]
        cell.configure(with: book)
        return cell
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer) {
        guard let header = sender.view as? SectionHeaderView else { return }
        seeAllTapped(section: header.sectionIndex, title: header.title, books: header.books)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       viewForSupplementaryElementOfKind kind: String,
                       at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeaderView",
                for: indexPath) as! SectionHeaderView
            
            var title = ""
            var books: [Book] = []
            switch displayedSections[indexPath.section] {
            case .currently:
                header.seeAllButton.isHidden = true
                if currentBook == nil {
                    title = ""
                }
                else {
                    title = "Currently"
                }
            case .recent:
                header.seeAllButton.isHidden = false
                title = "Recent"
                books = recentBooks
            case .wantToRead:
                header.seeAllButton.isHidden = false

                title = "Want to Read"
                books = wantToReadBooks
            case .category(let name, let bookList):
                header.seeAllButton.isHidden = false

                title = name
                books = bookList
            }
            header.titleLabel.text = title
            header.sectionIndex = indexPath.section
            header.title = title
            header.books = books

            header.seeAllAction = { [weak self] in
                self?.seeAllTapped(section: indexPath.section, title: title, books: books)
            }

            return header
        } else {
            return UICollectionReusableView()
        }
    }

}
class SectionHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    let seeAllButton = UIButton(type: .system)
    let separatorView = UIView()
    var sectionIndex: Int = 0
    var title: String = ""
    var books: [Book] = []
    var seeAllAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        separatorView.backgroundColor = .systemGray4
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])

        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .left
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.setTitleColor(.systemBlue, for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        addSubview(seeAllButton)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.addTarget(self, action: #selector(didTapSeeAll), for: .touchUpInside)

        // Layout: horizontal, padded
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: seeAllButton.leadingAnchor, constant: -8),

            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            seeAllButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func didTapSeeAll() {
        seeAllAction?()
    }
}
extension HomeViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if let cell = collectionView.cellForItem(at: indexPath) as? BookCell  {
////            
//            UIView.animate(withDuration: 0.4,
//                           animations: {
//                cell.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//                cell.contentView.transform = .identity
//            }
////            },
////                           completion: { _ in
////                UIView.animate(withDuration: 0.4) {
////                    cell.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
////                    
////                }
////        }
//        )
////
////            UIView.animate(withDuration: 1, animations: {
////                cell.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
////            }) { _ in
////                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
////                    UIView.animate(withDuration: 1) {
////                        cell.contentView.transform = .identity
////                    }
////                }
////            }
//        }
        
        
        switch indexPath.section {
        case 0:
            if let book = currentBook {
                bookCellTapped(book: book)
            }
        case 1:
            let book = recentBooks[indexPath.item]
            bookCellTapped(book: book)
        case 2:
            let book = wantToReadBooks[indexPath.item]
            bookCellTapped(book: book)
        default:
            let book = categories[indexPath.section - 3].books[indexPath.item]
            bookCellTapped(book: book)
        }
    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? YourCellClass else { return }
//
//        UIView.animate(withDuration: 0.1,
//                       animations: {
//                           cell.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//                       },
//                       completion: { _ in
//                           UIView.animate(withDuration: 0.1) {
//                               cell.contentView.transform = .identity
//                           }
//                       })
//    }
}
