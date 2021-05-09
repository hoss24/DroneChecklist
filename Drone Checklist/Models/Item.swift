//
//  Item.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/20/21.
//

import Foundation
import RealmSwift
//Item object is the data the user is seeing in the app when they click on a checklist category
// checklist items (i.e. check propellers for damage)
//inherit object to create Realm model object
class Item: Object {
    @objc dynamic var instructions: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var order: Int = 0
    //inverse relationship to a cateogry (parent category), of type Category from property items
    //link each item back to category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
