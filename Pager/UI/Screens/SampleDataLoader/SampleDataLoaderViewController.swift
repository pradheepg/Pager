//
//  SampleDataLoaderViewController.swift
//  Pager
//
//  Created by Pradheep G on 23/12/25.
//

import UIKit

class SampleDataLoaderViewController: UIViewController {
    private let bgImageView: UIImageView = UIImageView(image: UIImage(named: "alertBG"))
    
    override func viewDidLoad() {
        view.backgroundColor = AppColors.background
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            setUpAlerts()
        }
    
    func setUpAlerts() {
        let alert = UIAlertController(
            title: "Welcome!",
            message: "Would you like to load sample data to explore the app, or start with a fresh empty library?",
            preferredStyle: .alert
        )
        
        let loadAction = UIAlertAction(title: "Load Sample Data", style: .default) { [weak self] _ in
            self?.onOK()
        }
        
        let freshAction = UIAlertAction(title: "Start Fresh", style: .cancel) { [weak self] _ in
            self?.onCancel()
        }
        
        alert.addAction(loadAction)
        alert.addAction(freshAction)
        
        present(alert, animated: true)
    }
    
    func onCancel() {
        if let sceneDelegate = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            (sceneDelegate.delegate as? SceneDelegate)?.setTabBarAsRoot()
        }
    }
    
    func onOK() {
        print("User chose to load data.")
        print(UserSession.shared.currentUser?.profileName)
        setUpAlerts()
    }
    
    
    
    func setUpView() {
        view.addSubview(bgImageView)
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.alpha = 0.9
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
