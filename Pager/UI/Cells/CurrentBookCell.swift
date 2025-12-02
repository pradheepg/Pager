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
        contentView.addSubview(moreButton)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLablel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = .white
        authorLablel.font = .systemFont(ofSize: 14)
        authorLablel.numberOfLines = 0
        authorLablel.lineBreakMode = .byWordWrapping
        authorLablel.textColor = .white
        progressLabel.font = .systemFont(ofSize: 14)
        progressLabel.textColor = .white
        moreButton.setTitle("...", for: .normal)
        moreButton.contentHorizontalAlignment = .left
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            
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
        backgroundImageView.image = ViewHelper.getCoverImage(of: book)
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
