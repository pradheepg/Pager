//
//  GradientDecorationView.swift
//  Pager
//
//  Created by Pradheep G on 25/12/25.
//

import UIKit

class GradientDecorationView: UICollectionReusableView {
    static let elementKind = "gradient-background"
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
        updateGradientColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradientLayer() {
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateGradientColors()
        }
    }
    
    private func updateGradientColors() {
        let top = AppColors.gradientTopColor.resolvedColor(with: self.traitCollection).cgColor
        let bottom = AppColors.gradientBottomColor.resolvedColor(with: self.traitCollection).cgColor
        gradientLayer.colors = [top, bottom]
    }
}
