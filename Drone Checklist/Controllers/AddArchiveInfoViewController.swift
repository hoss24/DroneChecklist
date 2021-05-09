//
//  AddArchiveInfoViewController.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 4/1/21.
//

import UIKit
import CoreLocation
import Eureka

//delegate will take data input by user to add to Archive
protocol AddArchiveInfoViewControllerDelegate{
    func archiveLists(_ dateTime: Date, _ locationName: String, _ latitude: Double, _ longitude: Double, _ pilotName: String, _ droneModel: String, _ notes: String, _ hours: Int, _ minutes: Int, _ seconds: Int)
}

//get additional information regarding flight operations from users to add to archive of checklists
class AddArchiveInfoViewController: FormViewController {
    
    var delegate: AddArchiveInfoViewControllerDelegate?
    //responsible for getting current GPS location
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var latitude = 0.0
    var longitude = 0.0
    var lastNameInput: String? = nil
    var lastDroneModelInput: String? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(false, animated: true)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        navigationItem.title = "Add Archive Info"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        createToolbar()
        createForm()
    }
    
    func createToolbar(){
        //toolbar buttons
        //create spacer so a click anywhere on bar will result in action
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(doneTapped))
        let finish = UIBarButtonItem(title: "Finish & Archive Data", style: .plain, target: self, action: #selector(doneTapped))
        finish.width = view.frame.size.width
        setToolbarItems([spacer, finish, spacer], animated: false)
        //show toolbar
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.toolbar.barTintColor = UIColor(rgb: 0x3498db)
    }
    
    func createForm(){
        //Utilzing Eureka
        form
            +++ Section("Operation Information (Optional)")
                <<< DateTimeInlineRow("Date & Time"){
                    $0.title = "Date & Time"
                    $0.value = Date()
                }
                <<< NameRow("Location Name") {
                    $0.title =  "Location Name"
                    $0.placeholder = "Location Name"
                    $0.value = ""
                }
                <<< LocationRow("Location"){
                    $0.title = "Location"
                    $0.value = CLLocation(latitude: latitude, longitude: longitude)
                }
                <<< NameRow("Pilot Name") {
                    $0.title =  "Pilot Name"
                    $0.placeholder = "Pilot Name"
                    $0.value = lastNameInput ?? ""
                }
                <<< NameRow("Drone Model") {
                    $0.title =  "Drone Model"
                    $0.placeholder = "Drone Model"
                    $0.value = lastDroneModelInput ?? ""
                }
                <<< TextAreaRow("Notes") {
                    $0.placeholder = "Notes"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                }
            +++ Section("Total Flight Time (Optional)")
                <<< PickerInputRow<String>("Hours"){
                    $0.title = "Hours"
                    $0.options = []
                    for i in 0...50{
                        $0.options.append("\(i) Hours")
                    }
                    $0.value = $0.options.first
                }
                <<< PickerInputRow<String>("Minutes"){
                    $0.title = "Minutes"
                    $0.options = []
                    for i in 0...60{
                        $0.options.append("\(i) Minutes")
                    }
                    $0.value = $0.options.first
                }
                <<< PickerInputRow<String>("Seconds"){
                    $0.title = "Seconds"
                    $0.options = []
                    for i in 0...60{
                        $0.options.append("\(i) Seconds")
                    }
                    $0.value = $0.options.first
                }
    }
    
    // MARK: - Navigation
    @objc func doneTapped() {
        let valuesDictionary = form.values()
        func stringCheck(_ value: String) -> String {
            if let safeNotes = valuesDictionary[value] as? String{
                return safeNotes
            }else{
                return ""
            }
        }
        let dateTime = valuesDictionary["Date & Time"] as! Date
        let locationName = stringCheck("Location Name")
        let location = valuesDictionary["Location"] as! CLLocation
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        let pilotName = stringCheck("Pilot Name")
        let droneModel = stringCheck("Drone Model")
        let notes = stringCheck("Notes")
        
        var hoursStr = valuesDictionary["Hours"] as! String
        hoursStr = hoursStr.onlyDigits
        let hours = Int(hoursStr)!
        
        var minutesStr = valuesDictionary["Minutes"] as! String
        minutesStr = minutesStr.onlyDigits
        let minutes = Int(minutesStr)!
        
        var secondsStr = valuesDictionary["Seconds"] as! String
        secondsStr = secondsStr.onlyDigits
        let seconds = Int(secondsStr)!
        
        delegate?.archiveLists(dateTime, locationName, latitude, longitude, pilotName, droneModel, notes, hours, minutes, seconds)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelTapped() {
        _ = navigationController?.popViewController(animated: true)
    }

}
//MARK: - CLLocationManagerDelegate
//get location if able and set as the value in field
extension AddArchiveInfoViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            form.setValues(["Location" : CLLocation(latitude: latitude, longitude: longitude)])
            tableView.reloadData()
            locationManager?.stopUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        latitude = 0
        longitude = 0
    }
    
}
