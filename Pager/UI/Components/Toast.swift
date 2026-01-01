//
//  Toast.swift
//  Pager
//
//  Created by Pradheep G on 26/12/25.
//

import UIKit

class Toast {
    
    static func show(message: String, icon: String? = nil, in view: UIView) {
        
        let container = UIView()
        container.backgroundColor = UIColor.label.withAlphaComponent(0.7)
        container.layer.cornerRadius = 20
        container.clipsToBounds = true
        container.alpha = 0
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        if let iconName = icon {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: iconName)
            imageView.tintColor = .systemBackground
            imageView.contentMode = .scaleAspectFit
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 24),
                imageView.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            stack.addArrangedSubview(imageView)
        }
        
        let label = UILabel()
        label.text = message
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .systemBackground
        label.numberOfLines = 2
        stack.addArrangedSubview(label)
        
        container.addSubview(stack)
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            container.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            container.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
        
        container.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            container.alpha = 1
            container.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            UIView.animate(withDuration: 0.3, animations: {
                container.alpha = 0
                container.transform = CGAffineTransform(translationX: 0, y: 10)
            }) { _ in
                container.removeFromSuperview()
            }
        }
    }
}
