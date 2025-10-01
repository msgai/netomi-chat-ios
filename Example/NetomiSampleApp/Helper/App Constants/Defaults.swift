//
//  Defaults.swift
//  NetomiSampleApp
//
//  Created by Netomi on 20/11/24.
//

import Foundation

struct Defaults {
  
  enum Keys: String {
    case email = "email"
    case name = "name"
    case isLoggedIn = "isLoggedIn"
  }
  
  private static let preserveValues: [Keys] = []
  
  static func removeUnPreservedData() {
    for i in UserDefaults.standard.dictionaryRepresentation() {
      if let key = Defaults.Keys(rawValue: i.key), preserveValues.contains(key) {
        debugPrint("Preserved-->",i.key)
      } else {
        debugPrint("Deleted-->",i.key)
        UserDefaults.standard.removeObject(forKey: i.key)
        UserDefaults.standard.synchronize()
      }
    }
  }
  
  static var email: String? {
    get {
      let email = UserDefaults.standard.string(forKey: Keys.email.rawValue)
      return email
    }
    set {
      UserDefaults.standard.set(newValue, forKey: Keys.email.rawValue)
      UserDefaults.standard.synchronize()
    }
  }
  
  static var name: String? {
    get {
      let name = UserDefaults.standard.string(forKey: Keys.name.rawValue)
      return name
    }
    set {
      UserDefaults.standard.set(newValue, forKey: Keys.name.rawValue)
      UserDefaults.standard.synchronize()
    }
  }
  
  static var isLoggedIn: Bool {
    get {
      return !(Defaults.email?.isEmpty ?? true)
    }
  }
}
