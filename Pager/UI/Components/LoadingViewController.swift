//
//  LoadingViewController.swift
//  Pager
//
//  Created by Pradheep G on 08/12/25.
//

import UIKit

class LoadingViewController: UIViewController {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        return spinner
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Preparing Book..."
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7) // Semi-transparent black
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 180),
            containerView.heightAnchor.constraint(equalToConstant: 140),
            
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10),
            
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 15),
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}
