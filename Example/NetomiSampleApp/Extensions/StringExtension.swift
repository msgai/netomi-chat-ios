//
//  StringExtension.swift
//  NetomiSampleApp
//
//  Created by Netomi on 14/11/24.
//

import UIKit

enum ValidityExression : String {
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+\\.[A-Za-z]{2,}"
    case emailDoubleDot = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+\\.[A-Za-z]{2,}+\\.[A-Za-z]{2,}"
    case password = "^.{1,128}$"
}

extension String {
    
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return trimmed.isEmpty
        }
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func checkIfInvalid(_ validityExression : ValidityExression) -> Bool {
        if validityExression == .email {
            return !(self.checkIfValid(.email) || self.checkIfValid(.emailDoubleDot))
        } else {
            return !self.checkIfValid(validityExression)
        }
    }
    
    func checkIfValid(_ validityExression : ValidityExression) -> Bool {
        
        let regEx = validityExression.rawValue
        
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        
        return test.evaluate(with: self)
    }
}
