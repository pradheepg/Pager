//
//  EmptyMyBooksView.swift
//  Pager
//
//  Created by Pradheep G on 01/12/25.
//

import UIKit

class EmptyMyBooksViewController: UIViewController {
    private let imageView: UIImageView = UIImageView()
    private let messageLable: UILabel = UILabel()
    private let bookStoreButton: UIButton = UIButton()
    private let containerView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        
        view.addSubview(containerView)
        containerView.backgroundColor = AppColors.secondaryBackground
        containerView.backgroundColor = AppColors.background
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(imageView)
        imageView.image = UIImage(named: "emptyStateImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(messageLable)
        messageLable.text = "You haven’t purchased any books!"
        messageLable.font = .systemFont(ofSize: 20,weight: .semibold)
        messageLable.textColor = AppColors.title
        messageLable.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(bookStoreButton)
        bookStoreButton.setTitle(" Browse Book Store", for: .normal)
        bookStoreButton.setImage(UIImage(systemName: "bag"), for: .normal)
        bookStoreButton.tintColor = .label
        bookStoreButton.setTitleColor(AppColors.title, for: .normal)
        bookStoreButton.setTitleColor(AppColors.subtitle, for: .highlighted)
        bookStoreButton.backgroundColor = UIColor.systemGray6
        bookStoreButton.layer.cornerRadius = 14
        bookStoreButton.layer.masksToBounds = true
        bookStoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        bookStoreButton.semanticContentAttribute = .forceLeftToRight
        bookStoreButton.translatesAutoresizingMaskIntoConstraints = false

        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),

            containerView.topAnchor.constraint(equalTo: imageView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bookStoreButton.bottomAnchor),

            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            messageLable.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            messageLable.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),

            bookStoreButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bookStoreButton.topAnchor.constraint(equalTo: messageLable.bottomAnchor, constant: 10),
            bookStoreButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6),
            bookStoreButton.heightAnchor.constraint(equalToConstant: 50),
        ])

        
//        NSLayoutConstraint.activate([
//            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
//            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
//
//            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
//            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            imageView.widthAnchor.constraint(equalToConstant: 150),
//            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
//            
//            messageLable.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            messageLable.topAnchor.constraint(equalTo: imageView.bottomAnchor),
//            
//            bookStoreButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            bookStoreButton.topAnchor.constraint(equalTo: messageLable.bottomAnchor, constant: 10 ),
//            bookStoreButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6),
//            bookStoreButton.heightAnchor.constraint(equalToConstant: 50),
//            
//        ])
    }
}
