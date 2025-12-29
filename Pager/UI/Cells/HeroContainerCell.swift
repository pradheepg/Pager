//
//  HeroContainerCell.swift
//  Pager
//
//  Created by Pradheep G on 02/12/25.
//

import UIKit

class HeroContainerCell: UICollectionViewCell {
    static let reuseID = "HeroContainerCell"
    
    private let heroView = NewReleaseHeroView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(heroView)
        heroView.translatesAutoresizingMaskIntoConstraints = false
        
        // Pin HeroView to the edges of the cell content
        NSLayoutConstraint.activate([
            heroView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with book: Book, action: @escaping () -> Void) {
        heroView.configure(with: book)
        heroView.onButtonTapped = action
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
