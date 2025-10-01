//
//  AppImages.swift
//  NetomiSampleApp
//
//  Created by Netomi on 14/11/24.
//

import UIKit

enum AppImages {
    static let showPassword             = UIImage(named: "showPassword")
    static let hidePassword             = UIImage(named: "hidePassword")
    static let password                 = UIImage(named: "password")
    static let name                     = UIImage(named: "name")
    static let email                    = UIImage(named: "email")
    static let number                   = UIImage(named: "number")
    static let messageIcon              = UIImage(named: "messageIcon")
}

class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
}

extension UIImageView {
    // Function to load image with caching
    func loadImage(from url: String, placeholder: UIImage? = nil) {
        // Check if the image is already cached
        if let placeholder {
            self.image = placeholder
        }
        guard let url = URL(string: url) else { return }
        if let cachedImage = ImageCacheManager.shared.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        
        // If not cached, download the image
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                return
            }
            
            // Cache the image
            ImageCacheManager.shared.setObject(image, forKey: url.absoluteString as NSString)
            
            // Update the image view on the main thread
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
