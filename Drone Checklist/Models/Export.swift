//
//  Export.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 4/11/21.
//

import Foundation
//object containing export properties
class Export: NSObject {
    var dateTime: Date?
    var locationName: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var pilotName: String = ""
    var droneModel: String = ""
    var notes: String = ""
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var checklists = [String]()
}
