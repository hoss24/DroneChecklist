//
//  ShowArchiveInfoViewController.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 4/12/21.
//

import Foundation
import UIKit

//view controller for showing archive info when a specific archive is selected by the user
class ShowArchiveInfoViewController: UIViewController {
    var archiveInfo = Export()
    @IBOutlet var infoTextView: UITextView!
    
    override func viewDidLoad() {
        navigationController?.setToolbarHidden(true, animated: false)
        navigationItem.title = "Archived Item Info"
        infoTextView.isEditable = false
        infoTextView.showsVerticalScrollIndicator = true
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let date = archiveInfo.dateTime!
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "MMM d, YYYY, HH:mm:ss"
        // Convert Date to String
        let dateString = dateFormatter.string(from: date)

        var infoLabelText = " Date & Time: " + dateString
        infoLabelText += " \n \n Location Name: " + archiveInfo.locationName
        infoLabelText += " \n \n Location Latitude: " + String(archiveInfo.latitude)
        infoLabelText += " \n \n Location Longitude: " + String(archiveInfo.longitude)
        infoLabelText += " \n \n Pilot Name: " + archiveInfo.pilotName
        infoLabelText += " \n \n Drone Model: " + archiveInfo.droneModel
        infoLabelText += " \n \n Notes: " + archiveInfo.notes
        infoLabelText += " \n \n Hours: " + String(archiveInfo.hours)
        infoLabelText += " \n \n Minutes: " + String(archiveInfo.minutes)
        infoLabelText += " \n \n Seconds: " + String(archiveInfo.seconds)
        
        for category in archiveInfo.checklists{
            infoLabelText += " \n \n Checklist: " + category
        }
        infoTextView.text = infoLabelText
    }
    
}
