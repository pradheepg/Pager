//
//  BookCollectionCell.swift
//  Pager
//
//  Created by Pradheep G on 05/01/26.
//

import UIKit

class BookCollectionCell: UITableViewCell {
    
    static let identifier = "BookCollectionCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(countLabel)
        
        let guide = contentView.layoutMarginsGuide
        let spacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            countLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            
            nameLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -spacing),
            
            nameLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
    
    func configure(with name: String?, count: Int) {
        nameLabel.text = name
        countLabel.text = "\(count)"
        setNeedsLayout()
        layoutIfNeeded()
    }
}
