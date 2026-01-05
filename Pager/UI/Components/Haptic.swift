//
//  Haptic.swift
//  Pager
//
//  Created by Pradheep G on 05/01/26.
//

import UIKit

class Haptics {
    static let shared = Haptics()
    
    private init() {}
    
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
