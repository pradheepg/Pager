//
//  SampleDataLoaderViewController.swift
//  Pager
//
//  Created by Pradheep G on 23/12/25.
//

import UIKit
import CoreData

class SampleDataLoaderViewController: UIViewController {
    private let bgImageView: UIImageView = UIImageView(image: UIImage(named: "alertBG"))
    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.color = .gray
        return spinner
    }()
    override func viewDidLoad() {
        view.backgroundColor = AppColors.background
        super.viewDidLoad()
        setUpView()
        view.addSubview(loadingSpinner)
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
//        loadingSpinner.startAnimating()
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
        self.loadingSpinner.startAnimating()
        Task {
            await try? Task.sleep(nanoseconds: 10000000000)
            if let user = UserSession.shared.currentUser {
                do{
                    let request: NSFetchRequest<Book> = Book.fetchRequest()
                    let books = try CoreDataManager.shared.context.fetch(request)
                    await DemoUserData.shared.populateSampleData(user: user, allBooks: books)
                } catch {
                    print("Error loading the data")
                }
            }
            DispatchQueue.main.async {
                self.loadingSpinner.stopAnimating()
                if let sceneDelegate = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    (sceneDelegate.delegate as? SceneDelegate)?.setTabBarAsRoot()
                }
            }
        }
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
