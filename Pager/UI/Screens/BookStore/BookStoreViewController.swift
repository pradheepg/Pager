//
//  BookStoreViewController.swift
//  Pager
//
//  Created by Pradheep G on 24/11/25.
//

import UIKit

class BookStoreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private let heroView = NewReleaseHeroView()
    private var featuredBook: Book? = nil
    private let categoryLable: UILabel = UILabel()
    private let categoryCollectionView: UICollectionView
    private var popularBook: [Book] = []
    private var categories: [(name: String, books: [Book])] = []
    private var collectionView: UICollectionView!
    private let mainScrollView: UIScrollView = UIScrollView()
    private let contentView = UIView()

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        let demotemp = BookRepository()
        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
        switch sampleBooks {
        case .success(let books):
            if let book = books.last {
                featuredBook = book
            }
        case .failure(let error):
            print(error.localizedDescription)
            print(error)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Book store"
        setUpScrollView()
        setUpHeroCard()
        setUpCategory()
        setupCollectionView()
        loadDemoData()

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
    
    private func setUpHeroCard() {
        guard let featuredBook = featuredBook else {
            return
        }
        contentView.addSubview(heroView)
        heroView.translatesAutoresizingMaskIntoConstraints = false
        heroView.configure(with: featuredBook)
        heroView.onButtonTapped = { [weak self] in
            guard let self = self, let book = self.featuredBook else { return }
            
            let detailVC = DetailViewController(book: book)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
        NSLayoutConstraint.activate([
            heroView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            heroView.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
        ])
        
    }
    
    private func setUpCategory() {
        contentView.addSubview(categoryLable)
        categoryLable.text = "Categories"
        categoryLable.font = .systemFont(ofSize: 20, weight: .semibold)
        categoryLable.textColor = AppColors.title
        categoryLable.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.addSubview(categoryCollectionView)
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.register(CategoryPillCell.self,
                                        forCellWithReuseIdentifier: CategoryPillCell.reuseID)
        
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        
        NSLayoutConstraint.activate([
            categoryLable.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: 10),
            categoryLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            categoryLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            categoryLable.heightAnchor.constraint(lessThanOrEqualToConstant: 30),
            
            categoryCollectionView.topAnchor.constraint(equalTo: categoryLable.bottomAnchor,constant: 10),
            categoryCollectionView.leadingAnchor.constraint(equalTo: categoryLable.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: categoryLable.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            
        ])
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return CategoryEnum.allCases.count
        } else {
            return categories[section].books.count
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == categoryCollectionView {
            return 1
        }
        else {
            return categories.count
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryPillCell.reuseID,
                for: indexPath
            ) as! CategoryPillCell
            
            let item = CategoryEnum.allCases[indexPath.item]
            cell.configure(title: item.rawValue, systemImageName: item.systemImageName)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.reuseID, for: indexPath) as! BookCell
            
            let item = categories[indexPath.section].books[indexPath.item]
            cell.configure(with: item)
            return cell
        }
    }
    
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        
        
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, environment in
            
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
    
    private func loadDemoData() {
        let demotemp = BookRepository()
        let sampleBooks: Result<[Book], BookError> = demotemp.fetchAllBooks()
        switch sampleBooks {
        case .success(let books):
            popularBook = books
        case .failure(let error):
            print(error.localizedDescription)
            print(error)
        }
        
        var defaultCategoryName = "cat 1"
        
        categories.append((name: defaultCategoryName, books: popularBook))
        defaultCategoryName = "cat 2"
        categories.append((name: defaultCategoryName, books: popularBook))
        defaultCategoryName = "cat 3"
        categories.append((name: defaultCategoryName, books: popularBook))
        defaultCategoryName = "cat 4"
        categories.append((name: defaultCategoryName, books: popularBook))
        
        collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeaderView",
                for: indexPath) as! SectionHeaderView
            
            let title = categories[indexPath.section].name
            let books: [Book] = categories[indexPath.section].books
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
    func seeAllTapped(section: Int,title: String, books: [Book]) {
        let vc = BookGridViewController(categoryTitle: title, books: books)
        self.navigationController?.pushViewController(vc, animated: true)
        print("See All tapped for section \(section)")
        
    }
}
