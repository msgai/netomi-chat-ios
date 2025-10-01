//
//  NSAButton.swift
//  NetomiSampleApp
//
//  Created by Netomi on 14/11/24.
//

import Foundation
import UIKit

class NSAButton: UIButton {
    
    @IBInspectable
    open var customCornerRadius: CGFloat = 4 {
        didSet {
            self.layer.cornerRadius = customCornerRadius
        }
    }
    
    @IBInspectable
    open var textColor: UIColor? = AppColors.themeWhite {
        didSet {
            self.setTitleColor(textColor, for: .normal)
        }
    }
    
    @IBInspectable
    open var backColor: UIColor? = AppColors.themeColor {
        didSet {
            self.backgroundColor = backColor
        }
    }
    
    @IBInspectable
    open var isEnable: Bool = false {
        didSet {
            self.isUserInteractionEnabled = self.isEnable
            self.alpha = isEnable ? 1.0 : 0.3
        }
    }
    
    @IBInspectable
    open var applyGradient: Bool = false
    
    @IBInspectable
    open var firstColor: UIColor? = nil
    
    @IBInspectable
    open var secondColor: UIColor? = nil
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if applyGradient {
            self.gradientLayer?.removeFromSuperlayer()
            gradientLayer = CAGradientLayer()
            gradientLayer.frame.size = self.frame.size
            gradientLayer.colors = [firstColor?.cgColor as Any, secondColor?.cgColor as Any]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            self.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            self.gradientLayer?.removeFromSuperlayer()
        }
        updateView()
    }
    
    private var gradientLayer: CAGradientLayer!
    
    fileprivate func updateView() {
        self.layer.cornerRadius = customCornerRadius
        self.layer.masksToBounds = true
        self.backgroundColor = backColor
        self.setTitleColor(textColor, for: .normal)
        self.isUserInteractionEnabled = self.isEnable
        self.alpha = isEnable ? 1.0 : 0.3
    }

}
