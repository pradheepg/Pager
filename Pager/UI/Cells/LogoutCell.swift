//
//  logoutCell.swift
//  Pager
//
//  Created by Pradheep G on 18/12/25.
//

import UIKit

class LogoutCell: UITableViewCell {
    var onLogoutTapped: (() -> Void)?
    static let resueKey = "LogoutCell"
    
    private let footerButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill // We use constraints to sizing
        return stack
    }()
    
    private let logOutButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Logout"
        config.image = UIImage(systemName: "iphone.and.arrow.right.outward")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .systemRed
        
        let button = UIButton(configuration: config)
        return button // No need for translatesAutoresizing... in stack view usually
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none // Prevent cell from turning gray on tap
        
        contentView.addSubview(footerButtonStack)
//        footerButtonStack.addArrangedSubview(changePasswordButton)
        footerButtonStack.addArrangedSubview(logOutButton)
        
        // Setup Actions
//        changePasswordButton.addTarget(self, action: #selector(didTapChangePasswordButton), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupConstraints() {
        // 2. FIX: Constrain to 'contentView', not 'view'
        // And fix the position (center it with padding)
        NSLayoutConstraint.activate([
            // Pin Stack to edges of cell content
            footerButtonStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            footerButtonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            footerButtonStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            footerButtonStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            
            // Set Button Proportions (60% / 40%)
            // Note: Since spacing exists, we use 0.58 roughly or let Auto Layout handle it with equal spacing
//            changePasswordButton.widthAnchor.constraint(equalTo: footerButtonStack.widthAnchor, multiplier: 0.60)
        ])
    }
    
//    @objc private func didTapChangePasswordButton() {
//        // 3. Delegate the action to the Controller
//        onChangePasswordTapped?()
//    }
    
    @objc private func didTapLogoutButton() {
        // 3. Delegate the action to the Controller
        onLogoutTapped?()
    }
}
