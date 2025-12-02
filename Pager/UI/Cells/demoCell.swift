//
//  demoCell.swift
//  Pager
//
//  Created by Pradheep G on 27/11/25.
//
import UIKit

final class DemoCell: UICollectionViewCell {

    static let reuseID = "DemoCell"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .systemBlue
        contentView.layer.cornerRadius = 12

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "Demo"

        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(index: Int) {
        label.text = "Item \(index)"
    }
}
