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

        contentView.backgroundColor = UIColor.systemGray6
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        iconView.tintColor = .label
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)

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
