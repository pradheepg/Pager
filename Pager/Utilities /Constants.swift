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
            //            print("color \(trait.userInterfaceStyle == .dark) ",UITraitCollection.current.userInterfaceStyle == .dark)
            return trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
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
            : UIColor.systemGray5
        }
    }()
    
    static let secondaryBackground: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? .secondarySystemBackground
            : .secondarySystemBackground
        }
    }()
    
    static let illustrationTint: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.black
            : UIColor.white
        }
    }()
    
    static let gradientTopColor: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
            : UIColor.white
        }
    }()
    
    static let gradientBottomColor: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.black
            : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
    }()
    
    static let readingGoalButtonBGColoe: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? AppColors.secondaryBackground
            : AppColors.title
        }
    }()
    
    static let readingGoalButtonTitleColoe: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? AppColors.title
            : AppColors.background
        }
    }()
    
    static let gridViewBGColor: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? AppColors.background
            : AppColors.secondaryBackground
        }
    }()
    
    static let gridViewSecondaryColor: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? AppColors.secondaryBackground
            : AppColors.background
        }
    }()
    
    static let systemBlue: UIColor = {
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#B150E2")
            : UIColor(hex: "#B150E2")
        }
    }()
    
    static let text: UIColor = {
            return UIColor { trait in
                return trait.userInterfaceStyle == .dark ? .white : .black
            }
        }()
        
        static let secondaryText: UIColor = {
            return UIColor { trait in
                return trait.userInterfaceStyle == .dark ? .lightGray : .darkGray
            }
        }()
        
        // Tile Background (Dark Gray vs Secondary System Background)
        static let tileBackground: UIColor = {
            return UIColor { trait in
                return trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.12, alpha: 1.0) // Custom Dark Gray
                : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0) // Soft Gray
            }
        }()
    
    
    static let readBookBgDark: UIColor = {
        return UIColor.black
    }()
    
    static let readBookBgLight: UIColor = {
        return UIColor(hex: "#F2F2F7")
    }()
    
    static let readBookFgDark: UIColor = {
        return UIColor.white
    }()
    
    static let readBookFgWhite: UIColor = {
        return UIColor.black //(hex: "#8A8A8E")
    }()
    
    static let readBookSecondaryDark: UIColor = {
        return UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1.0)
    }()
    
    static let readBookSecondaryWhite: UIColor = {
        return UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1.0)// UIColor(hex: "#767680")
    }()
        
    static let readBookButtonActiveDark: UIColor = {
        return UIColor(red: 0.39, green: 0.39, blue: 0.40, alpha: 1.0)
    }()

    static let readBookButtonActiveLight: UIColor = {
        return UIColor.white
    }()

    static let readBookButtonDeActiveDark: UIColor = {
        return UIColor.clear
    }()

    static let readBookButtonDeActiveLight: UIColor = {
        return UIColor.clear
    }()

    static let readBookButtonLabelActiveDark: UIColor = {
        return UIColor.white
    }()

    static let readBookButtonLabelActiveLight: UIColor = {
        return UIColor.black
    }()

    static let readBookButtonLabelDeActiveDark: UIColor = {
        return UIColor.systemGray2
    }()

    static let readBookButtonLabelDeActiveLight: UIColor = {
        return UIColor.systemGray
    }()}

enum KeychainKeys {
    static let serviceAuth = "com.pager.auth"
    static let accountUserID = "loggedInUserId"
}

enum CategoryEnum: String, CaseIterable {
    case novels    = "Novels"       // Covers: Fiction, Romance, Drama
    case thriller  = "Thriller"   // Covers: Mystery, Crime, Suspense
    case fantasy   = "Fantasy"    // Covers: Sci-Fi, Magic, Dystopian
    case business  = "Business"   // Covers: Finance, Career, Money
    case biography = "Biography"  // Covers: Memoirs, History, People
    case kids      = "Kids"
    
    
    var systemImageName: String {
        switch self {
        case .novels:    return "book.closed.fill"   // Represents a standard storybook
        case .thriller:  return "eye.fill"           // Represents mystery, watching, suspense
        case .fantasy:   return "sparkles"           // Represents magic, sci-fi, and wonder
        case .business:  return "briefcase.fill"     // Represents work, finance, career
        case .biography: return "person.fill"        // Represents an individual's life
        case .kids:      return "teddybear.fill"     // Represents toys and children
        }
    }
    
}

extension UIViewController {
    
    func showToast(title: String? = nil, message: String, duration: TimeInterval = 1.2, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        self.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alert.dismiss(animated: true) {
                completion?()
            }
//            completion?()

        }
    }
    
    var isModal: Bool {
            if let nav = navigationController {

                if nav.viewControllers.first != self {
                    return false
                }
                return nav.presentingViewController != nil
            }
            return presentingViewController != nil
        }
}


class DefaultsName {
    static let wantToRead: String = "Want to Read"
    static let finiahed: String = "Finished"
}

enum ContentLimits {
    static let reviewMinTitleLength = 3
    static let reviewMinBodyLength = 10
    static let reviewMaxTitleLength = 100
    static let reviewMaxBodyLength = 2000
    
    static let userMinNameLength = 2
    static let userMaxNameLength = 60
    static let userMinEmailLength = 5
    static let userMaxEmailLength = 254
    static let passwordMinLength = 6
//    static let passwordMaxLength = 
    
    static let collectiomMinNameLength = 5
    static let collectionMaxNameLength = 50
    
    
}
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
