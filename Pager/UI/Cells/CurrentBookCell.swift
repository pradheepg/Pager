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
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLablel)
        contentView.addSubview(progressLabel)
        contentView.addSubview(moreButton)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLablel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        authorLablel.font = .systemFont(ofSize: 12)
        authorLablel.numberOfLines = 0
        authorLablel.lineBreakMode = .byWordWrapping
        progressLabel.font = .systemFont(ofSize: 12)
        moreButton.setTitle("...", for: .normal)
        moreButton.contentHorizontalAlignment = .left
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
//        NSLayoutConstraint.activate([
//            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
//            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
//            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor,constant: -10),
//            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 5),
//            progressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
//            progressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            moreButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            moreButton.centerYAnchor.constraint(equalTo:titleLabel.centerYAnchor, constant: 50),
//        ])
        NSLayoutConstraint.activate([
            // Book cover: fixed aspect ratio (2:3, width:height)
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            // Aspect ratio constraint (width : height = 2 : 3)
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 2.0/3.0),
            
            // Title next to book cover
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor,constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            //Author
            authorLablel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            authorLablel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLablel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Progress below title
            progressLabel.topAnchor.constraint(equalTo: authorLablel.bottomAnchor, constant: 6),
            progressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // More button below progress
            moreButton.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 10),
            moreButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            moreButton.trailingAnchor.constraint(lessThanOrEqualTo: titleLabel.trailingAnchor),
            moreButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])

    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(with book: Book) {
        
        imageView.image = ViewHelper.getCoverImage(of: book)
        titleLabel.text = book.title
        authorLablel.text = book.author
        var progress = 0
        if let userBookRecords = UserSession.shared.currentUser?.owned as? Set<UserBookRecord> {
            for record in userBookRecords {
                if record.book == book {
                    progress = Int(record.progressValue)
                }
            }
        }
        progressLabel.text = "\(progress)%"
    }

    @objc private func moreTapped() { moreButtonAction?() }
}
