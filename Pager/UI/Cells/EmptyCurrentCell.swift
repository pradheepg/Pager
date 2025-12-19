//
//  EmptyCurrentCell.swift
//  Pager
//
//  Created by Pradheep G on 26/11/25.
//
import UIKit

//class EmptyCurrentCell: UICollectionViewCell {
//    let messageLabel = UILabel()
//    let actionButton = UIButton(type: .system)
//    var buttonAction: (() -> Void)?
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        messageLabel.frame = CGRect(x: 0, y: 0, width: 120, height: 36)
//        actionButton.frame = CGRect(x: 0, y: 40, width: 120, height: 36)
//        contentView.addSubview(messageLabel)
//        contentView.addSubview(actionButton)
//        messageLabel.textAlignment = .center
//        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
//    }
//    required init?(coder: NSCoder) { fatalError() }
//    func configure(message: String, buttonTitle: String) {
//        messageLabel.text = message
//        actionButton.setTitle(buttonTitle, for: .normal)
//    }
//    @objc private func buttonTapped() { buttonAction?() }
//}
class EmptyCurrentCell: UICollectionViewCell {
    let messageLabel = UILabel()
    let actionButton = UIButton(type: .system)
    var buttonAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        messageLabel.textColor = AppColors.subtitle
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle("Explore the Book Store", for: .normal)
        actionButton.setImage(UIImage(systemName: "bag"), for: .normal)
        actionButton.tintColor = .label
        actionButton.setTitleColor(.label, for: .normal)
        actionButton.backgroundColor = UIColor.systemGray6
        actionButton.layer.cornerRadius = 14
        actionButton.layer.masksToBounds = true
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        actionButton.semanticContentAttribute = .forceLeftToRight
//        actionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
//        actionButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        contentView.addSubview(messageLabel)
        contentView.addSubview(actionButton)
        
        messageLabel.textAlignment = .center
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.widthAnchor.constraint(equalToConstant: 300),
            messageLabel.heightAnchor.constraint(equalToConstant: 36),
            
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            actionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 300),
            actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(message: String, buttonTitle: String) {
        messageLabel.text = message
//        actionButton.setTitle(buttonTitle, for: .normal)
    }

    @objc private func buttonTapped() { buttonAction?() }
}
