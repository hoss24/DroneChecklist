//
//  CategoryArchive.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 4/1/21.
//

import Foundation
import RealmSwift
// checklist categories the user has archived as part of an archive
//inherit object to create Realm model object
class CategoryArchive: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var order: Int = 0
    // allows us to set checklist item done value to false if checklist is archived
    @objc dynamic var uniqueID: String = ""
    //relationship, use Realm List similar to an array like let array5 = Array<Int>()
    //forward relationship as inside each Category items will point to a List of Item
    var parentCategory = LinkingObjects(fromType: Archive.self, property: "categoryArchive")
    var items = List<Item>()
}
