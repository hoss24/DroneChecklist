//
//  Extensions.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/31/21.
//

import UIKit
import Realm
import RealmSwift

//MARK: - Detachable Realm
//Realm detachable option so when an item is copied it is not tied to original object
protocol RealmListDetachable {
    func detached() -> Self
}
extension List: RealmListDetachable where Element: Object {
    func detached() -> List<Element> {
        let detached = self.detached
        let result = List<Element>()
        result.append(objectsIn: detached)
        return result
    }
}
@objc extension Object {
    public func detached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            if let detachable = value as? Object {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else if let list = value as? RealmListDetachable {
                detached.setValue(list.detached(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
}
extension Sequence where Iterator.Element: Object {
    public var detached: [Element] {
        return self.map({ $0.detached() })
    }
}

//MARK: - Hex Color Converter
//color conversion from hex #______ to UIColor
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }
   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

//MARK: - String Filtering Options
extension String {
    private func filterCharacters(unicodeScalarsFilter closure: (UnicodeScalar) -> Bool) -> String {
        return String(String.UnicodeScalarView(unicodeScalars.filter { closure($0) }))
    }

    private func filterCharacters(definedIn charSets: [CharacterSet], unicodeScalarsFilter: (CharacterSet, UnicodeScalar) -> Bool) -> String {
        if charSets.isEmpty { return self }
        let charSet = charSets.reduce(CharacterSet()) { return $0.union($1) }
        return filterCharacters { unicodeScalarsFilter(charSet, $0) }
    }
    func removeCharacters(charSets: [CharacterSet]) -> String { return filterCharacters(definedIn: charSets) { !$0.contains($1) } }
    func removeCharacters(charSet: CharacterSet) -> String { return removeCharacters(charSets: [charSet]) }
    func onlyCharacters(charSets: [CharacterSet]) -> String { return filterCharacters(definedIn: charSets) { $0.contains($1) } }
    func onlyCharacters(charSet: CharacterSet) -> String { return onlyCharacters(charSets: [charSet]) }
}

extension String {
    var onlyDigits: String { return onlyCharacters(charSets: [.decimalDigits]) }
    var onlyLetters: String { return onlyCharacters(charSets: [.letters]) }
}
