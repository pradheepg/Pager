//
//  SceneDelegate.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        seedDatabaseIfEmpty()
        
        if checkForLogin() {
            window?.rootViewController = MainTabBarController()
        }
        else {
            let navController = UINavigationController(rootViewController: WelcomeViewController())
            window?.rootViewController = navController
        }
        SceneDelegate.applySavedTheme()
        window?.makeKeyAndVisible()
    }

    func seedDatabaseIfEmpty() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                DataLoader.shared.loadSeedData(context: context)
            } else {
                print("Database already contains data. Skipping seed.")
            }
        } catch {
            print("Error checking database: \(error)")
        }
    }
    func setTabBarAsRoot() {
        let tabBarVC = MainTabBarController()
        window?.rootViewController = tabBarVC
        SceneDelegate.applySavedTheme()
        window?.makeKeyAndVisible()
    }
    
    func checkForLogin() -> Bool {
        return UserSession.shared.loadSession()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    
    func deleteAll() {
        let context = CoreDataManager.shared.context
        try? deleteAllObjects(of: "Book", in: context)
        try? deleteAllObjects(of: "User", in: context)
        try? deleteAllObjects(of: "Review", in: context)
        try? deleteAllObjects(of: "Collection", in: context)
        try? deleteAllObjects(of: "UserBookRecord", in: context)
    }
    
    func deleteAllObjects(of entityName: String, in context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // For keeping the context in sync with the store
        deleteRequest.resultType = .resultTypeObjectIDs

        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        if let objectIDs = result?.result as? [NSManagedObjectID] {
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        }
    }
}

extension SceneDelegate {
    static func setRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        
        window.rootViewController = vc
        
        if animated {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    static func applySavedTheme() {
            // 1. Read the saved index (0=System, 1=Light, 2=Dark)
            let savedIndex = UserDefaults.standard.integer(forKey: "selectedThemeIndex")
            
            // 2. Determine the Style
            let style: UIUserInterfaceStyle
            switch savedIndex {
            case 1:
                style = .light
            case 2:
                style = .dark
            default:
                style = .unspecified // Follow System
            }
            
            // 3. Apply to all active windows
            // We iterate through connected scenes to find the window
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.windows.forEach { window in
                        // This forces the change with an animation
                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                            window.overrideUserInterfaceStyle = style
                        }, completion: nil)
                    }
                }
            }
        }
}
