//
//  ArchiveCategory.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 4/1/21.
//

import Foundation
import RealmSwift
import CoreLocation
//archive of checklists the user has already completed and additional data they added to the archive
//inherit object to create Realm model object
class Archive: Object {
    @objc dynamic var dateTime: Date?
    @objc dynamic var locationName: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var pilotName: String = ""
    @objc dynamic var droneModel: String = ""
    @objc dynamic var notes: String = ""
    @objc dynamic var hours: Int = 0
    @objc dynamic var minutes: Int = 0
    @objc dynamic var seconds: Int = 0
    @objc dynamic var selectedToExport: Bool = false
    //relationship, use Realm List similar to an array like let array5 = Array<Int>()
    //forward relationship as inside each Category items will point to a List of Item
    var categoryArchive = List<CategoryArchive>()
}

