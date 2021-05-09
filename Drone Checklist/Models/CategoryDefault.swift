//
//  CategoryDefault.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 4/27/21.
//

import Foundation
import RealmSwift

//Object holding default checklists that are provided when the app is first installed, stored for reset option
//inherit object to create Realm model object
class CategoryDefault: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var order: Int = 0
    @objc dynamic var selectedToArchive: Bool = false
    @objc dynamic var uniqueID: String = ""
    //relationship, use Realm List similar to an array like let array5 = Array<Int>()
    //forward relationship as inside each Category items will point to a List of Item
    var items = List<Item>()
}
