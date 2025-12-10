//
//  BookGridCell.swift
//  Pager
//
//  Created by Pradheep G on 25/11/25.
//

import UIKit

class BookGridCell: UICollectionViewCell {
    static let reuseID = "BookGridCell"
    
    let coverImageView = UIImageView()
    let titleLabel = UILabel()
    let authorLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        coverImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label
        
        authorLabel.font = .systemFont(ofSize: 14)
        authorLabel.textColor = .secondaryLabel
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, authorLabel])
        stack.axis = .vertical
        stack.spacing = 2
//        contentView.backgroundColor = AppColors.secondaryBackground
        contentView.addSubview(coverImageView)
        contentView.addSubview(stack)
        
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 3/2),
//            coverImageView.widthAnchor.constraint(equalToConstant: 120),
//            coverImageView.heightAnchor.constraint(equalToConstant: 160),
            
            stack.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
//            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with book: Book) {
        coverImageView.image = ViewHelper.getCoverImage(of: book)
        titleLabel.text = book.title
        authorLabel.text = book.author
    }
}
