//
//  ReviewCell.swift
//  Pager
//
//  Created by Pradheep G on 27/11/25.
//
import UIKit

final class ReviewCell: UICollectionViewCell {
    private let container: UIView = UIView()
    private let reviewTitleLable: UILabel = UILabel()
    private let reviewContentLable: UILabel = UILabel()
    private let startStack: UIStackView = UIStackView()
    private let metaLable: UILabel = UILabel()
    private let formatter = DateFormatter()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy"
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        startStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setUpUI() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(container)
        container.backgroundColor = AppColors.secondaryBackground
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
//        container.addSubview(reviewTitleLable)
        reviewTitleLable.numberOfLines = 0
        reviewTitleLable.font = .systemFont(ofSize: 20, weight: .semibold)
        reviewTitleLable.textAlignment = .left
        reviewTitleLable.textColor = AppColors.title
        
//        container.addSubview(reviewContentLable)
        reviewContentLable.numberOfLines = 0
        reviewContentLable.font = .systemFont(ofSize: 16)
        reviewContentLable.textAlignment = .left
        reviewContentLable.textColor = AppColors.title
        
//        container.addSubview(startStack)
//        setUpStarStack(rating: 3)
        
        
//        container.addSubview(metaLable)
        metaLable.numberOfLines = 0
        metaLable.textAlignment = .left
        metaLable.font = .systemFont(ofSize: 14)
        metaLable.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        
        let bottomRow = UIStackView(arrangedSubviews: [startStack, metaLable])
        bottomRow.axis = .horizontal
        bottomRow.spacing = 8
        bottomRow.alignment = .center
        bottomRow.translatesAutoresizingMaskIntoConstraints = false

        let vStack = UIStackView(arrangedSubviews: [reviewTitleLable, reviewContentLable, bottomRow])
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
        ])
    }
    
    private func setUpStarStack(rating: Int) {
            startStack.axis = .horizontal
            startStack.spacing = 8
            startStack.alignment = .center
            startStack.translatesAutoresizingMaskIntoConstraints = false
            startStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            let clamped = min(max(rating, 0), 5)

            for _ in 0..<clamped {
//                let img = UIImageView(image: UIImage(systemName: "star.fill"))
//                img.tintColor = .systemYellow
//                startStack.addArrangedSubview(img)
                startStack.addArrangedSubview(makeStar(named: "star.fill", tint: .systemYellow))
            }

            for _ in 0..<(5 - clamped) {
//                let img = UIImageView(image: UIImage(systemName: "star"))
//                img.tintColor = .systemGray
//                startStack.addArrangedSubview(img)
                startStack.addArrangedSubview(makeStar(named: "star", tint: .systemYellow))
            }
        }
    
    func makeStar(named name: String, tint: UIColor) -> UIImageView {
        let img = UIImageView(image: UIImage(systemName: name))
        img.tintColor = tint
        img.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            img.widthAnchor.constraint(equalToConstant: 16),
            img.heightAnchor.constraint(equalToConstant: 16)
        ])
        return img
    }

    func configure(with review: Review) {
        reviewTitleLable.text = review.reviewTitle
        reviewContentLable.text = review.reviewText
        
        if let date = review.dateEdited ?? review.dataCreated{
            metaLable.text = "\(formatter.string(from: date)), \(review.postedBy?.profileName ?? "guest user")"
        }
        setUpStarStack(rating: Int(review.rating))
    }
}

