//
//  Constants.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import UIKit

enum AppColors {
    static let background: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
    }()
    
    static let button: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 100/255, green: 80/255, blue: 180/255, alpha: 1)
                : UIColor.systemPurple
        }
    }()
    
    static let buttonBorder: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
                : UIColor(red: 147/255, green: 154/255, blue: 164/255, alpha: 1)
        }
    }()
    
    static let buttonBorderEditing: UIColor = {
        return UIColor { trait in
            AppColors.button
        }
    }()
    
    static let disableText: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.lightGray
            : UIColor.white
        }
    }()
    
    static let disableButton: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 60/255, green: 50/255, blue: 120/255, alpha: 1)
                : UIColor.systemPurple.withAlphaComponent(0.4)
        }
    }()
    
    static let buttonText: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.white
        }
    }()
    
    static let subtitle: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.lightGray
                : UIColor.darkGray
        }
    }()
    
    static let title: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor.black
        }
    }()
    
    static let textFieldBackground: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.15, alpha: 1)
                : UIColor.white
        }
    }()

    static let illustrationTint: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.black
                : UIColor.white
        }
    }()
}

enum KeychainKeys {
    static let serviceAuth = "com.pager.auth"
    static let accountUserID = "loggedInUserId"
//    static let accountAuthToken = "authToken"
}
