//
//  Category.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/20/21.
//

import Foundation
import RealmSwift

//Category object is the data the user is seeing in the app when they first go to checklists
//checklist category (i.e. Pre-Flight, Documentation, etc..)
//inherit object to create Realm model object
class Category: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var order: Int = 0
    @objc dynamic var selectedToArchive: Bool = false
    // allows us to set checklist item done value to false if checklist is archived
    @objc dynamic var uniqueID: String = ""
    //relationship, use Realm List similar to an array like let array5 = Array<Int>()
    //forward relationship as inside each Category items will point to a List of Item
    var items = List<Item>()
}


