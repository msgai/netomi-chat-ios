//
//  Defaults.swift
//  NetomiSampleApp
//
//  Created by Netomi on 20/11/24.
//


import Foundation
import UIKit

enum AppFonts : String {
    case regular = "ProximaNova-Regular"
    case bold = "Proxima Nova Bold"
    case semiBold = "Proxima Nova Alt Semibold"
    
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func withSize(_ fontSize: CGFloat) -> UIFont {
        let newSize = AppFonts.isIPad ? fontSize * 1.2 : fontSize
        return UIFont(name: rawValue, size: newSize) ?? UIFont.systemFont(ofSize: newSize)
    }
    
    func withDefaultSize() -> UIFont {
        let newSize: CGFloat = AppFonts.isIPad ? 18 : 12
        return UIFont(name: rawValue, size: newSize) ?? UIFont.systemFont(ofSize: newSize)
    }
}

extension UIFont {
    
    @objc class func appRegularFont(ofSize size: CGFloat) -> UIFont {
        let newSize = AppFonts.isIPad ? size * 1.2 : size
        return UIFont(name: AppFonts.regular.rawValue, size: newSize) ?? UIFont.systemFont(ofSize: size)
    }
    
    @objc class func appBoldFont(ofSize size: CGFloat) -> UIFont {
        let newSize = AppFonts.isIPad ? size * 1.2 : size
        return UIFont(name: AppFonts.bold.rawValue, size: newSize) ?? UIFont.systemFont(ofSize: size)
    }
    
    @objc class func appItalicFont(ofSize size: CGFloat) -> UIFont {
        let newSize = AppFonts.isIPad ? size * 1.2 : size
        return UIFont(name: AppFonts.regular.rawValue, size: newSize) ?? UIFont.systemFont(ofSize: size)
    }
    
    @objc class func appMediumFont(ofSize size: CGFloat) -> UIFont {
        let newSize = AppFonts.isIPad ? size * 1.2 : size
        return UIFont(name: AppFonts.regular.rawValue, size: newSize) ?? UIFont.systemFont(ofSize: size)
    }
    
    @objc convenience init?(myCoder aDecoder: NSCoder) {
        guard let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor else {
            print("Failed to decode UIFontDescriptor")
            self.init(coder: aDecoder)
            return
        }
        
        // Attempt to fetch the font attribute
        let fontAttribute = fontDescriptor.fontAttributes[.textStyle] as? String ?? "CTFontRegularUsage"
        
        let fontName: String
        switch fontAttribute {
        case "CTFontRegularUsage":
            fontName = AppFonts.regular.rawValue
        case "CTFontEmphasizedUsage", "CTFontBoldUsage":
            fontName = AppFonts.bold.rawValue
        case "CTFontObliqueUsage":
            fontName = AppFonts.regular.rawValue
        case "CTFontHeavyUsage":
            fontName = AppFonts.bold.rawValue
        case "CTFontDemiUsage", "CTFontMediumUsage":
            fontName = AppFonts.semiBold.rawValue
        default:
            fontName = AppFonts.regular.rawValue
        }
        
        let newSize = AppFonts.isIPad ? fontDescriptor.pointSize * 1.2 : fontDescriptor.pointSize
        if let customFont = UIFont(name: fontName, size: newSize) {
            let customDescriptor = customFont.fontDescriptor
            self.init(descriptor: customDescriptor, size: newSize) // ✅ Safe initialization
        } else {
            print("⚠️ Failed to load custom font: \(fontName), falling back to system font")
            self.init(descriptor: fontDescriptor, size: newSize) // ✅ Fallback
        }
    }
    
    class func overrideInitialize() {
        guard self == UIFont.self else { return }
        let methodSwizzles: [(Selector, Selector)] = [
            (#selector(systemFont(ofSize:)), #selector(appRegularFont(ofSize:))),
            (#selector(boldSystemFont(ofSize:)), #selector(appBoldFont(ofSize:))),
            (#selector(italicSystemFont(ofSize:)), #selector(appItalicFont(ofSize:))),
        ]
        
        for (original, custom) in methodSwizzles {
            guard let originalMethod = class_getClassMethod(self, original),
                  let customMethod = class_getClassMethod(self, custom) else { continue }
            method_exchangeImplementations(originalMethod, customMethod)
        }
        
        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))),
           let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}
