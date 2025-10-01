//
//  UIViewExtension.swift
//  NetomiSampleApp
//
//  Created by Netomi on 14/11/24.
//

import UIKit

extension UIView {
    
    ///Sets the corner radius of the view
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    ///Sets the border width of the view
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    ///Sets the border color of the view
    @IBInspectable var borderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    var height: CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }
    
}

extension UITextField {
    func addDoneToolbar(title: String = "Done", target: Any?, action: Selector) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: title, style: .done, target: target, action: action)

        // iOS 15+: style (optional)
        if #available(iOS 15.0, *) {
            toolbar.tintColor = .label
            toolbar.barTintColor = .systemBackground
            toolbar.isTranslucent = true
        }

        toolbar.items = [flex, done]
        self.inputAccessoryView = toolbar
    }
}

extension UIView {
    var currentFirstResponder: UIResponder? {
        if isFirstResponder { return self }
        for sub in subviews {
            if let r = sub.currentFirstResponder { return r }
        }
        return nil
    }
}
