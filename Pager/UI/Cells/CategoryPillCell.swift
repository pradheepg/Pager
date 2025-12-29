//
//  CategeryPillCell.swift
//  Pager
//
//  Created by Pradheep G on 02/12/25.
//
import UIKit

class CategoryPillCell: UICollectionViewCell {
    static let reuseID = "CategoryPillCell"
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = AppColors.gridViewSecondaryColor
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        iconView.tintColor = .label
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 2, height: 6)
        layer.masksToBounds = false

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, systemImageName: String) {
        titleLabel.text = title
        iconView.image = UIImage(systemName: systemImageName)
    }
}
