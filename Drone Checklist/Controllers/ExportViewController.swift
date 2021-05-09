//
//  ExportViewController.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/19/21.
//

import UIKit
import RealmSwift
import CoreLocation

//display archived data with option to view, delete, and export
class ExportViewController: SwipeTableViewController {
    //initalize new Realm
    let realm = try! Realm()
    //stored data from when checklists are archived
    var archives: Results<Archive>?
    var exportArr = [Export]()
    var export: Export!
    var exportToView = Export()
    var isExporting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadArchives()
        createBars()
    }
    
    // MARK: - Toolbar
    func createBars(){
        //toolbar buttons
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let select = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectTapped))
        let selectAllButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectTapped))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(exportCancelled))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        share.accessibilityLabel = "Share selected archives"
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelected))
        delete.accessibilityLabel = "Delete selected archives"
        //bar button for spacing
        let spacer2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        spacer2.width = cancel.width
        
        //set toolbar/navbar buttons based on current state
        if isExporting{
            setToolbarItems([spacer2, spacer, selectAllButton, spacer, cancel], animated: false)
            if let safeArchives = archives{
                for archive in safeArchives{
                    if archive.selectedToExport {
                        setToolbarItems([share, spacer, selectAllButton, spacer, delete], animated: false)
                        break
                    }
                }
            }
            navigationItem.setHidesBackButton(true, animated: true)
            navigationItem.title = "Select Data"
            navigationItem.rightBarButtonItem = cancel
        }else if isEditing{
            setToolbarItems([spacer], animated: false)
            navigationItem.setHidesBackButton(true, animated: true)
            navigationItem.title = "Editing"
            navigationItem.rightBarButtonItem = select
        }
        else{
            navigationItem.title = "Export"
            navigationItem.setHidesBackButton(false, animated: true)
            if tableView.cellForRow(at: [0,0]) != nil {
                setToolbarItems([spacer, select, spacer], animated: false)
                navigationItem.rightBarButtonItem = select
            }
            else{
                setToolbarItems([spacer], animated: false)
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        //show toolbar
        navigationController?.setToolbarHidden(false, animated: false)
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.allowsMultipleSelectionDuringEditing = isExporting ? true : false
        //tap into cell that gets created inside superclass at indexPath
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let safeArchives = archives{
            let date = safeArchives[indexPath.row].dateTime!
            // Create Date Formatter
            let dateFormatter = DateFormatter()
            // Set Date Format
            dateFormatter.dateFormat = "MMM d, YYYY, HH:mm:ss"
            // Convert Date to String
            let dateString = dateFormatter.string(from: date)
            cell.textLabel?.text = safeArchives[indexPath.row].locationName
            cell.detailTextLabel?.text = dateString
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.numberOfLines = 0
            //accessibility labeling
            if isEditing && safeArchives[indexPath.row].selectedToExport == false{
                cell.accessibilityLabel = "Archive Unselected. " + safeArchives[indexPath.row].locationName + dateString + ". Double tap to select archive for exporting."
            } else if isEditing && safeArchives[indexPath.row].selectedToExport == true {
                cell.accessibilityLabel = "Archive Selected. " + safeArchives[indexPath.row].locationName + dateString + ". Double tap to deselect archive from exporting."
            } else{
                cell.accessibilityLabel = safeArchives[indexPath.row].locationName + dateString
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let safeArchives = archives{
            if isExporting && safeArchives[indexPath.row].selectedToExport{
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }else{
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    //MARK: - Update Data
    func updateSelection (at indexPath: IndexPath){
        if let safeArchives = archives{
            let archive = safeArchives[indexPath.row]
                do {
                    try realm.write {
                        //toggle realm value between selected/unselected
                        archive.selectedToExport = !archive.selectedToExport
                    }
                } catch {
                    print("error saving done status \(error)")
                }
            self.tableView.reloadData()
        }
    }
    func updateSelectionAll (selected: Bool){
        if let safeArchives = archives{
            for archive in safeArchives {
                do {
                    try realm.write {
                        archive.selectedToExport = selected
                    }
                } catch {
                    print("error saving done status \(error)")
                }
            }
            tableView.reloadData()
        }
    }
    
    //MARK: - Delete Data
    func updateModel(at indexPath: IndexPath) {
        // handle action by updating model with deletion
        do {
            try realm.write {
                if let safeArchives = archives{
                    for category in safeArchives[indexPath.row].categoryArchive {
                        realm.delete(category.items)
                    }
                    realm.delete(safeArchives[indexPath.row].categoryArchive)
                    realm.delete(safeArchives[indexPath.row])
                }
            }
        } catch {
            print("error deleting category \(error)")
        }
    }
    
    @objc func deleteSelected() {
        let alertController = UIAlertController(title: "Confirm Deletion of Archives", message: "", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            // Code in this block will trigger when OK button is tapped.
            if let safeArchives = self.archives{
                for archive in safeArchives{
                    if archive.selectedToExport{
                        do {
                            try self.realm.write {
                                for category in archive.categoryArchive {
                                    self.realm.delete(category.items)
                                }
                                self.realm.delete(archive.categoryArchive)
                                self.realm.delete(archive)
                            }
                        } catch {
                            print("error deleting category \(error)")
                        }
                    }
                }
            }
            self.setEditing(false, animated: true)
            self.isExporting = false
            if self.isEditing == false{
                self.tableView.reloadData()
            }
            self.createBars()
        }
        let CancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) in
            self.isExporting = false
            self.setEditing(false, animated: true)
            self.isExporting = false
            if self.isEditing == false{
                self.tableView.reloadData()
            }
            self.createBars()
        }
        alertController.addAction(OKAction)
        alertController.addAction(CancelAction)
        self.present(alertController, animated: true, completion:nil)

    }
    
    //MARK: - TableView Delegate Methods
    //what happens when we click
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //
        if isEditing && isExporting  {
            updateSelection(at: indexPath)
        }else if !isEditing{
            if let safeArchives = archives{
                let archive = safeArchives[indexPath.row]
                exportToView.dateTime = archive.dateTime!
                exportToView.locationName = archive.locationName
                exportToView.latitude = archive.latitude
                exportToView.longitude = archive.longitude
                exportToView.pilotName = archive.pilotName
                exportToView.droneModel = archive.droneModel
                exportToView.notes = archive.notes
                exportToView.hours = archive.hours
                exportToView.minutes = archive.minutes
                exportToView.seconds = archive.seconds
                exportToView.checklists.removeAll()
                let categories = archive.categoryArchive.sorted(byKeyPath: "order", ascending: true)
                for category in categories{
                    var checklist = "\(category.title)"
                    let items = category.items.sorted(byKeyPath: "order", ascending: true)
                    for item in items{
                        //add new line
                        checklist += "\n   \(item.instructions): \(item.done ? "Checked" : "Unchecked")"
                    }
                    exportToView.checklists.append("\(checklist)")
                }
                performSegue(withIdentifier: "addArchivetoShowArchive", sender: self)
            }
        }
        createBars()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing && isExporting {
            updateSelection(at: indexPath)
        }
        createBars()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            updateModel(at: indexPath)
            loadArchives()
         }
    }
    
    //MARK: - Toolbar Button Methods
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)

        // Toggle table view editing.
        tableView.setEditing(editing, animated: true)
        //finished editing or finished selecting items to archive or cancelled archiving
        if !isEditing{
            if isExporting{
                //export data
                var safeToExport = false
                if let safeArchives = archives{
                    for archive in safeArchives {
                        if archive.selectedToExport {
                            export = Export()
                            export.dateTime = archive.dateTime!
                            // Add double quotes in case user input includes a period or comma, would mess up csv without.
                            export.locationName = "\"" + archive.locationName + "\""
                            export.latitude = archive.latitude
                            export.longitude = archive.longitude
                            export.pilotName = "\"" + archive.pilotName + "\""
                            export.droneModel = "\"" + archive.droneModel + "\""
                            export.notes = "\"" + archive.notes + "\""
                            export.hours = archive.hours
                            export.minutes = archive.minutes
                            export.seconds = archive.seconds
                            let categories = archive.categoryArchive.sorted(byKeyPath: "order", ascending: true)
                            for category in categories{
                                var checklist = "\"\(category.title)"
                                let items = category.items.sorted(byKeyPath: "order", ascending: true)
                                for item in items{
                                    //add new line
                                    checklist += "\n   \(item.instructions): \(item.done ? "Checked" : "Unchecked")"
                                }
                                checklist += "\"" //add " at end
                                export.checklists.append("\(checklist)")
                            }
                            exportArr.append(export!)
                            safeToExport = true
                        }
                    }
                }
                
                if safeToExport {
                    createCSV()
                }
            }
            isExporting = false
            updateSelectionAll(selected: false)
        }
        createBars()
    }

    @objc func selectTapped() {
        if !isEditing {
            isExporting = true
            isEditing = true
            createBars()
            tableView.reloadData()
        } else{
            updateSelectionAll(selected: true)
            createBars()
        }
    }
    @objc func exportCancelled() {
        updateSelectionAll(selected: false)
        isExporting = false
        setEditing(false, animated: true)
        createBars()
    }

    @objc func shareTapped() {
        setEditing(false, animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return archives?.count ?? 0
    }
    
    //MARK: - Load Data
    func loadArchives() {
        //start auto updating categories
        archives = realm.objects(Archive.self).sorted(byKeyPath: "dateTime", ascending: false) //return type of results which contains categories
        tableView.reloadData()
    }
    
    // MARK: CSV file creation
    func createCSV() -> Void {
        //Current date
        let date = Date()
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "MMMd_YYYY_HH_mm_ss"
        // Convert Date to String
        let dateString = dateFormatter.string(from: date)

        
        
        
        let fileName = "Export_\(dateString).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        //column names
        var csvText = "Date & Time, Location Name, Location Latitude, Location Longitude, Pilot Name, Drone Model, Notes, Hours, Minutes, Seconds"
        //add a column for each checklist
        for _ in export.checklists{
            csvText += ", Checklist"
        }
        //new line (row)
        csvText += "\n"
        //for each export add info to the row
        for export in exportArr {
            
            // Set the current timezone
            dateFormatter.timeZone = .current
            // Set the format of the altered date.
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
            // Set the current date, altered by timezone.
            let dateString = dateFormatter.string(from: export.dateTime!)
            
            var newLine = "\(dateString),\(export.locationName),\(export.latitude),\(export.longitude),\(export.pilotName),\(export.droneModel),\(export.notes),\(export.hours),\(export.minutes),\(export.seconds)"
            var checklistCount = 0
            for _ in export.checklists{
                newLine += ",\(export.checklists[checklistCount])"
                checklistCount += 1
            }
            newLine += "\n"
            csvText.append(newLine)
        }
        //clear array as all data has been copied over
        exportArr.removeAll()

        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        print(path ?? "not found")
        let fileURL = path

        // Create the Array which including files to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(fileURL!)
        createPopover(with: filesToShare)
    }
    
    //MARK: - Popover View Controller (Share View)
    func createPopover(with filesToShare: [Any]){
        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        showUniversalLoadingView(true, loadingText: "Creating CSV...")
        present(activityViewController, animated: true, completion: hideLoading)
    }
    
    //MARK: - Loading View
    func hideLoading(){
        showUniversalLoadingView(false)
    }
    func showUniversalLoadingView(_ show: Bool, loadingText : String = "") {
        let existingView = UIApplication.shared.windows[0].viewWithTag(1200)
        if show {
            if existingView != nil {
                return
            }
            let loadingView = self.makeLoadingView(withFrame: UIScreen.main.bounds, loadingText: loadingText)
            loadingView?.tag = 1200
            UIApplication.shared.windows[0].addSubview(loadingView!)
        } else {
            existingView?.removeFromSuperview()
        }
        UIAccessibility.post(notification: .announcement, argument: "Creating CSV")
    }
    func makeLoadingView(withFrame frame: CGRect, loadingText text: String?) -> UIView? {
        let loadingView = UIView(frame: frame)
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.center = loadingView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        activityIndicator.tag = 100
        activityIndicator.accessibilityLabel = "Loading"

        loadingView.addSubview(activityIndicator)
        if !text!.isEmpty {
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            let cpoint = CGPoint(x: activityIndicator.frame.origin.x + activityIndicator.frame.size.width / 2, y: activityIndicator.frame.origin.y + 80)
            lbl.center = cpoint
            lbl.textColor = UIColor.white
            lbl.textAlignment = .center
            lbl.text = text
            lbl.tag = 1234
            loadingView.addSubview(lbl)
        }
        return loadingView
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addArchivetoShowArchive":
            let destinationVC = segue.destination as! ShowArchiveInfoViewController
            destinationVC.archiveInfo = exportToView
        default:
            print("error in segue")
        }
    }

}
