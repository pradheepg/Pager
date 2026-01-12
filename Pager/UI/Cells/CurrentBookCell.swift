//
//  CurrentBookCell.swift
//  Pager
//
//  Created by Pradheep G on 26/11/25.
//

import UIKit

class CurrentBookCell: UICollectionViewCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let authorLablel = UILabel()
    let progressLabel = UILabel()
    let moreButton = UIButton(type: .system)
    var moreButtonAction: (() -> Void)?
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.3
        iv.clipsToBounds = true
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLablel)
        contentView.addSubview(progressLabel)
        //        contentView.addSubview(moreButton)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLablel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byClipping
        titleLabel.textColor = .white
        authorLablel.font = .systemFont(ofSize: 14)
        authorLablel.numberOfLines = 0
        authorLablel.lineBreakMode = .byWordWrapping
        authorLablel.textColor = .white
        progressLabel.font = .systemFont(ofSize: 14)
        progressLabel.textColor = .white
        //        moreButton.setTitle("...", for: .normal)
        //        moreButton.contentHorizontalAlignment = .left
        //        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold) // Bigger size
        moreButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        moreButton.tintColor = .white
        
        // 2. Remove text alignment, images center by default which is good
        moreButton.contentHorizontalAlignment = .left
        
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        setupMoreMenu()
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 2.0/3.0),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor,constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            authorLablel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            authorLablel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLablel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            progressLabel.topAnchor.constraint(equalTo: authorLablel.bottomAnchor, constant: 6),
            progressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // More button below progress
//            moreButton.topAnchor.constraint(equalTo: progressLabel.bottomAnchor),
//            moreButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//             moreButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10), // Optional if button is last element
//            
//            // 3. Force a larger touch area (44x44 minimum)
//            moreButton.heightAnchor.constraint(equalToConstant: 44),
//            moreButton.widthAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    required init?(coder: NSCoder) { fatalError() }
    private func setupMoreMenu() {

        let collectionsMenu = UIDeferredMenuElement.uncached { [weak self] completion in
            guard let self = self else { return }
            
            let allCollections = UserSession.shared.currentUser?.collections?.allObjects as? [BookCollection] ?? []
            
            let collectionItems = allCollections.map { collection in
                UIAction(title: collection.name ?? "Untitled", image: UIImage(systemName: "folder")) { action in
                    print("Adding to \(collection.name ?? "")")
                }
            }
            
            let createNewAction = UIAction(title: "New Collection...", image: UIImage(systemName: "plus")) { action in
                print("Create new collection tapped")
            }
            
            let menu = UIMenu(title: "Add to Collection", image: UIImage(systemName: "folder.badge.plus"), children: collectionItems + [createNewAction])
            
            completion([menu])
        }
        
        let reviewAction = UIAction(title: "View Reviews", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
            //            self?.shareBook()
        }
        
        let wantToReadAction = UIAction(title: "Want to Read", image: UIImage(systemName: "bookmark")) { _ in
            print("Want to read tapped")
        }
        
        let removeAction = UIAction(title: "Remove book", image: UIImage(systemName: "minus.circle.fill"), attributes: .destructive) { _ in
            print("Report tapped")
        }
        
        let menu = UIMenu(title: "Options", children: [
            UIMenu(options: .displayInline, children: [wantToReadAction, reviewAction]),
            collectionsMenu,
            UIMenu(options: .displayInline, children: [removeAction])
        ])
        
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
    func configure(with book: Book, isProgressHide: Bool = false) {
        backgroundImageView.image = ViewHelper.getCoverImage(of: book)
        imageView.image = backgroundImageView.image//ViewHelper.getCoverImage(of: book)
        titleLabel.text = book.title
        authorLablel.text = book.author
        var progress:Float = 0
        if let userBookRecords = UserSession.shared.currentUser?.owned as? Set<UserBookRecord> {
            for record in userBookRecords {
                if record.book == book {
                    if record.percentageRead > 0 {
                        progress = Float(record.percentageRead)
                    } else if record.progressValue > 0 && record.totalPages > 0 {
                        progress = Float(record.progressValue + 1) / Float(record.totalPages) * 100
                    }
                }
            }
        }
        progressLabel.text = "\(String(format: "%.1f", progress))%"
        progressLabel.isHidden = isProgressHide
    }

    @objc private func moreTapped() { moreButtonAction?() }
}
