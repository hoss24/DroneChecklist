//
//  HomeViewController.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/18/21.
//

import UIKit
import RealmSwift

//display stats and navigation buttons
class HomeViewController: UIViewController {
    //load archives realm to determine current flight time and checklists completed
    let realm = try! Realm()
    var archives: Results<Archive>?
    
    //connect labels and buttons
    @IBOutlet var flightTimeLabel: UILabel!
    @IBOutlet var checklistLabel: UILabel!
    @IBOutlet var checklistsButton: UIButton!
    @IBOutlet var exportButton: UIButton!
    @IBOutlet var guideButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set text color for navigation bar title within app
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(rgb: 0xecf0f1)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        //set background color for navigation bar and toolbar within app
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x2c3e50)
        navigationController?.toolbar.barTintColor = UIColor(rgb: 0x2c3e50)
        navigationController?.navigationBar.tintColor = UIColor(rgb: 0xecf0f1)
        navigationController?.toolbar.tintColor = UIColor(rgb: 0xecf0f1)
        
        //set button properties
        setButtonProperties(button: checklistsButton)
        setButtonProperties(button: exportButton)
        setButtonProperties(button: guideButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //hide navigationBar and toolBar each time the main view appears
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isToolbarHidden = true
        loadArchives()
        calculateTotals()
    }
    
    func setButtonProperties(button: UIButton){
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        //round button edges
        button.layer.cornerRadius = 20.0
        button.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //reset navigation bar as view is disappearing
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: - Data Manipulation Methods
    //MARK: - Load Data
    func loadArchives() {
        //return type of results which contains archives
        archives = realm.objects(Archive.self)
    }
    
    func calculateTotals(){
        var flightHours = 0.0
        var checklistsArchived = 0
        if let archivesSafe = archives{
            //iterate through current archives
            for archive in archivesSafe{
                //calculate total flight hours and checklists completed based off of data archived by user
                flightHours += Double(archive.hours)
                flightHours += Double(archive.minutes) / 60
                flightHours += Double(archive.seconds) / 3600
                checklistsArchived += archive.categoryArchive.count
            }
        }
        //round flight hours down to whole number of hours
        let flightHoursRounded = flightHours.rounded(.down)
        //calculate minutes
        let flightMinutes = (flightHours - flightHoursRounded) * 60
        
        //convert flight time values to string and round to whole number
        let flightMinutesString = String(format: "%.0f", flightMinutes)
        let flightHoursString = String(format: "%.0f", flightHoursRounded)
        
        //set labels with values
        flightTimeLabel.text = "Flight Time: " + flightHoursString + " hr " + flightMinutesString + " min"
        checklistLabel.text = "Checklists Archived: \(checklistsArchived)"
    }
}

