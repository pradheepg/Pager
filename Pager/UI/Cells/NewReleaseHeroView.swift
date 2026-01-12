//
//  HeroBannerCard.swift
//  Pager
//
//  Created by Pradheep G on 02/12/25.
//

import UIKit

class NewReleaseHeroView: UIView {

    var onButtonTapped: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.4
        iv.clipsToBounds = true
        return iv
    }()
    
    private let eyebrowLabel: UILabel = {
        let label = UILabel()
        label.text = "JUST LANDED"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .systemGray2
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        return label
    }()
    
    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOpacity = 0.5
        iv.layer.shadowOffset = CGSize(width: 0, height: 5)
        iv.layer.shadowRadius = 10
        iv.layer.masksToBounds = false
        return iv
    }()
    
    private lazy var actionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "View Book →"
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(buttonTriggered), for: .touchUpInside)
        return btn
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupLayout() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(backgroundImageView)
        containerView.addSubview(eyebrowLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(authorLabel)
        containerView.addSubview(actionButton)
        containerView.addSubview(coverImageView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        eyebrowLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 220),
            
            backgroundImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            eyebrowLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            eyebrowLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: eyebrowLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: coverImageView.leadingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            
            coverImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            coverImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: 100),
            coverImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func configure(with book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.author
        
        if let imgName = book.coverImageUrl {
            let image = UIImage(named: imgName)
            coverImageView.image = image
            backgroundImageView.image = image
        } else {
            coverImageView.image = UIImage(systemName: "book.closed.fill")
            coverImageView.tintColor = .white
            backgroundImageView.backgroundColor = .darkGray
        }
    }
    
    @objc private func buttonTriggered() {
        onButtonTapped?()
    }
}
