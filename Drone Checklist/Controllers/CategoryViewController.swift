//
//  CategoryViewController.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/19/21.
//

import UIKit
import RealmSwift
import CoreLocation

//display checklist categories with options to edit and archive
class CategoryViewController: SwipeTableViewController, AddEditViewControllerDelegate, AddArchiveInfoViewControllerDelegate{
    //initalize new Realm
    let realm = try! Realm()
    //checklist category (i.e. Pre-Flight, Documentation, etc..)
    var categories: Results<Category>?
    //store data when checklist is archived
    var archive: Results<Archive>?
    // contains checklist items and checklist categories
    var categoriesArchive: Results<CategoryArchive>?
    //default checklist for user to restore checklist to if required
    var categoriesDefault: Results<CategoryDefault>?
    //storage of categories to archive when we go to add archive information
    var archiveCategoryStorage = [CategoryArchive] ()
    //store checklist category when it is being edited
    var categoryToEdit: Category?
    //name at index path selected
    var indexPathNameSelected = ""
    //if the user is selecting checklists to archive
    var isArchiving = false
    //if data has been archived sucessfully
    var dataArchiveSucess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navBarTitles
        navigationItem.title = "Checklists"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCategories()
        createBars()
        if dataArchiveSucess{
            showAlert(title: "Archive Sucessful", message: "Data has been archived and selected checklists have been reset.")
            dataArchiveSucess = false
        }
    }
    
    //toolbar and navigation bar
    func createBars(){
        //toolbar buttons
        //spacing
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        //create bar button items
        let edit = editButtonItem
        edit.accessibilityLabel = "Edit Checklists"
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        add.accessibilityLabel = "Add new checklist category"
        let archive = UIBarButtonItem(title: "Archive Data", style: .plain, target: self, action: #selector(archiveTapped))
        let selectAllButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(archiveTapped))
        let cancelArchive = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(archiveCancelled))
        let reset = UIBarButtonItem(title: "Reset Lists", style: .plain, target: self, action: #selector(resetTapped))
        let next = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        //bar button for spacing
        let spacer2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        spacer2.width = reset.width
        
        //set toolbar/navbar buttons based on current state
        if isArchiving{
            setToolbarItems([cancelArchive, spacer, selectAllButton], animated: false)
            navigationItem.setHidesBackButton(true, animated: true)
            navigationItem.rightBarButtonItem = next
        }else if isEditing{
            setToolbarItems([reset, spacer, add, spacer, spacer2], animated: false)
            navigationItem.setHidesBackButton(true, animated: true)
            navigationItem.rightBarButtonItem = edit
        }else{
            setToolbarItems([reset, spacer, add, spacer, archive], animated: false)
            navigationItem.setHidesBackButton(false, animated: true)
            if !tableView.visibleCells.isEmpty {
                navigationItem.rightBarButtonItem = edit
            }
            else{
                navigationItem.rightBarButtonItem = nil
            }
        }
        
        //show toolbar
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.toolbar.barTintColor = UIColor(rgb: 0x2c3e50)
        
        //heading
        navigationItem.accessibilityLabel = navigationItem.title
    }
    
    // MARK: - TableView Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //only allow multiple selection if isArchiving is true
        tableView.allowsMultipleSelectionDuringEditing = isArchiving ? true : false
        //tap into cell that gets created inside superclass at indexPath
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //add accessory to show can click on checklist category to go to checklist items
        cell.accessoryType = .disclosureIndicator
        //create bold/italic and regular attribute
        guard let boldAttribute = UIFont(name: "HelveticaNeue-BoldItalic", size: UIFont.labelFontSize) else {
            fatalError("""
                Failed to load the "CustomFont-Light" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        guard let regularAttribute = UIFont(name: "HelveticaNeue", size: UIFont.labelFontSize) else {
            fatalError("""
                Failed to load the "CustomFont-Light" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }

        //determine if all checklist items have been completed
        let checklistItems = categories![indexPath.row].items
        let count = checklistItems.count
        var doneCount = 0
        for item in checklistItems {
            if item.done{
                doneCount+=1
            }
        }
        //bold/italic greentext if all checklist items completed, regular default text otherwise
        if count == doneCount && count > 0{
            cell.textLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: boldAttribute)
            cell.textLabel?.textColor = UIColor(rgb: 0x27AE60)
        }else{
            cell.textLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: regularAttribute)
            cell.textLabel?.textColor = .none
        }
        
        if isArchiving && categories![indexPath.row].selectedToArchive == false{
            cell.accessibilityLabel = "Unselected. " + categories![indexPath.row].title + ". Double tap to select for archiving."
        } else if isArchiving && categories![indexPath.row].selectedToArchive == true{
            cell.accessibilityLabel = "Selected. " + categories![indexPath.row].title + ". Double tap to deselect from archiving."
        } else {
            cell.accessibilityLabel = categories![indexPath.row].title
        }
        
        cell.textLabel?.text = categories![indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if isEditing && !isArchiving{
            //allow user to edit order
            return true
        }else{
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //select/deselect rows
        if isArchiving && categories![indexPath.row].selectedToArchive{
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    //MARK: - Data Manipulation Methods
    //MARK: - Load Data
    func loadCategories() {
        //start auto updating categories
        //return type of results (essentially a realm array) which contains categories
        categories = realm.objects(Category.self).sorted(byKeyPath: "order", ascending: true)
        categoriesArchive = realm.objects(CategoryArchive.self).sorted(byKeyPath: "order", ascending: true)
        categoriesDefault = realm.objects(CategoryDefault.self).sorted(byKeyPath: "order", ascending: true)
        archive = realm.objects(Archive.self).sorted(byKeyPath: "dateTime", ascending: false)
        tableView.reloadData()
        //if first time opening app will set default categories
        if categoriesDefault?.count == 0 {
            addDefaultCategories()
        }
    }
    
    //MARK: - Add Data
    func addWithText(textInput addText: String) {
        let newCategory = Category()
        newCategory.title = addText
        newCategory.order = categories?.count ?? 0
        func randomString(length: Int) -> String {
          let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          return String((0..<length).map{ _ in letters.randomElement()! })
        }
        //used to identify category when archived
        newCategory.uniqueID = randomString(length: 10)
        //save updated array and reload view
        save(category: newCategory)
    }
    
    //MARK: - Save Data
    func save(category: Category) {
        //commit context to permanenet storage within container
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context: \(error)")
        }
        //reload to take into account new item in array
        //insert row instead of reloading all tableview data
        let indexPath = IndexPath(row: ((categories?.count ?? 1) - 1), section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: - Move Data Order
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //store category that has been moved before editing
        let categoryToMove = categories![sourceIndexPath.row]
        for category in categories! {
            //category current order
            let categoryOrder = category.order
            //if category moved to lower index path number
            if destinationIndexPath.row < sourceIndexPath.row{
                // anything (greater than or equal to destination) and (less than source plus one)
                if categoryOrder >= destinationIndexPath.row && categoryOrder < sourceIndexPath.row{
                    //add one to order
                    let newOrder = categoryOrder + 1
                    updateCategoryOrder(category: category, newOrder: newOrder)
                }
            }else{ //if category moved to higher index path number
                // anything less than or equal to destination and greater than source minus one
                if categoryOrder <= destinationIndexPath.row && categoryOrder > sourceIndexPath.row{
                    //subtract one from order
                    let newOrder = categoryOrder - 1
                    updateCategoryOrder(category: category, newOrder: newOrder)
                }
            }
        }
        //edit category order that was moved
        updateCategoryOrder(category: categoryToMove, newOrder: destinationIndexPath.row)
        loadCategories()
    }
    
    //MARK: - Update Data
    //updating within storage
    func updateCategoryOrder (category: Category, newOrder: Int){
        do {
            try realm.write {
                category.order = newOrder
            }
        } catch {
            print("error editing category \(error)")
        }
    }
    func updateWithText (textInput newText: String){
        do {
            try realm.write {
                categoryToEdit!.title = newText
            }
        } catch {
            print("error editing category \(error)")
        }
    }
    func updateSelection (at indexPath: IndexPath){
        if let category = categories?[indexPath.row]{
            do {
                try realm.write {
                    category.selectedToArchive = !category.selectedToArchive
                }
            } catch {
                print("error saving done status \(error)")
            }
        }
        self.tableView.reloadData()
    }
    func updateSelectionAll (selected: Bool){
        for category in categories! {
            do {
                try realm.write {
                    category.selectedToArchive = selected
                }
            } catch {
                print("error saving done status \(error)")
            }
        }
        tableView.reloadData()
    }
    //MARK: - Archive Data
    //recieve data from add archive info to create archive with checklist category and checklist item data
    func archiveLists(_ dateTime: Date, _ locationName: String, _ latitude: Double, _ longitude: Double, _ pilotName: String, _ droneModel: String, _ notes: String, _ hours: Int, _ minutes: Int, _ seconds: Int) {
        //create new archive from input data
        let newArchive = Archive()
        newArchive.dateTime = dateTime
        newArchive.locationName = locationName
        newArchive.latitude = latitude
        newArchive.longitude = longitude
        newArchive.pilotName = pilotName
        newArchive.droneModel = droneModel
        newArchive.notes = notes
        newArchive.hours = hours
        newArchive.minutes = minutes
        newArchive.seconds = seconds
        //add categories to archive
        for archiveCategory in archiveCategoryStorage{
            newArchive.categoryArchive.append(archiveCategory)
        }
        do {
            try realm.write {
                realm.add(newArchive)
            }
        } catch {
            print("Error saving context: \(error)")
        }
        //if checklist category was archived, set all checklist items done values to be false
        for archiveCategory in categoriesArchive!{
            for category in categories!{
                //check is category was archived using the uniqueID
                if category.uniqueID == archiveCategory.uniqueID{
                    for item in category.items{
                        do {
                            try realm.write {
                                item.done = false
                            }
                        } catch {
                            print("error saving done status \(error)")
                        }
                    }
                }
            }
        }
        dataArchiveSucess = true
    }
    //MARK: - Default Data
    func addDefaultCategories() {
        for category in categories!.detached{
            let categoryDefault = CategoryDefault()
            categoryDefault.title = category.title
            categoryDefault.order = category.order
            categoryDefault.uniqueID = category.uniqueID
            categoryDefault.items = category.items
            //save updated array
            do {
                try realm.write {
                    realm.add(categoryDefault)
                }
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    //MARK: - Alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        }
        let ResetAction = UIAlertAction(title: "Reset", style: .destructive) { (action:UIAlertAction!) in
            if title == "Reset Checklists"{
                self.resetTapped(confirmed: true)
            }
        }
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        
        if title == "Reset Checklists"{
            alertController.addAction(ResetAction)
            alertController.addAction(CancelAction)
        }else{
            alertController.addAction(OKAction)
        }
        self.present(alertController, animated: true, completion:nil)
    }
    
    //MARK: - Delete Data
    func updateModel(at indexPath: IndexPath) {
        //update the order of the other categories before deletion
        //store category that has been selected for deletion before editing order of other categories
        let categoryToDelete = categories![indexPath.row]
        if categories!.count > 1 {
            for category in categories! {
                let categoryOrder = category.order
                if categoryOrder > indexPath.row {
                    let newOrder = categoryOrder - 1
                    updateCategoryOrder(category: category, newOrder: newOrder)
                }
            }
        }
        // update model with deletion
        do {
            try realm.write {
                //delete checklist items then checklist category
                realm.delete(categoryToDelete.items)
                realm.delete(categoryToDelete)
            }
        } catch {
            print("error deleting category \(error)")
        }
        tableView.reloadData()
        createBars()
    }

    //MARK: - TableView Delegate Methods
    //what happens when we click
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //
        if isEditing {
            if isArchiving{
                updateSelection(at: indexPath)
            }
            else{
                categoryToEdit = categories![indexPath.row]
                indexPathNameSelected = categories![indexPath.row].title
                performSegue(withIdentifier: "categoryToAddEdit" , sender: indexPathNameSelected)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        else{
            performSegue(withIdentifier: "goToItems", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing && isArchiving {
            updateSelection(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            updateModel(at: indexPath)
            loadCategories()
         }
    }
    
    //MARK: - Bar Button Methods
    @objc func addTapped() {
        //same view controller for add or edit, so we do not want any text from an exisiting items to be displayed as it is an add not an edit
        indexPathNameSelected = ""
        performSegue(withIdentifier: "categoryToAddEdit" , sender: indexPathNameSelected)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the edit button's title
        super.setEditing(editing, animated: true)

        // Toggle table view editing
        tableView.setEditing(editing, animated: true)
        
        
        if isEditing{
            if isArchiving{
                navigationItem.title = "Select Lists"
            }else{
                navigationItem.title = "Editing"
                createBars()
            }
        //done editing or done selecting items to archive or cancelled archiving
        }else{
            if isArchiving{
                performSegue(withIdentifier: "categoryToAddArchiveInfo" , sender: indexPathNameSelected)
            }
            navigationItem.title = "Checklists"
            isArchiving = false
            if isEditing == false{
                tableView.reloadData()
            }
            createBars()
            updateSelectionAll(selected: false)
        }
    }
    @objc func archiveTapped() {
        if !isEditing {
            isArchiving = true
            isEditing = true
            createBars()
            tableView.reloadData()
        } else{
            updateSelectionAll(selected: true)
        }
    }
    @objc func archiveCancelled() {
        updateSelectionAll(selected: false)
        navigationItem.rightBarButtonItem = nil
        isArchiving = false
        setEditing(false, animated: true)
    }
    @objc func nextTapped() {
        setEditing(false, animated: true)
    }
    @objc func resetTapped(confirmed: Bool) {
        // if alert confirmed
        if confirmed{
            //clear current checklist data
            if let safeCategories = categories {
                for category in safeCategories{
                    do {
                        try realm.write {
                            realm.delete(category.items)
                            realm.delete(category)
                        }
                    } catch {
                        print("error deleting category \(error)")
                    }
                }
            }
            //replace with default checklists
            if let safeCategoriesDefault = categoriesDefault?.detached {
                for categoryDefault in safeCategoriesDefault{
                    let category = Category()
                    category.title = categoryDefault.title
                    category.order = categoryDefault.order
                    category.uniqueID = categoryDefault.uniqueID
                    category.items = categoryDefault.items
                    do {
                        try realm.write {
                            realm.add(category)
                        }
                    } catch {
                        print("error deleting category \(error)")
                    }
                }
            }
            tableView.reloadData()
        }else{
            showAlert(title: "Reset Checklists", message: "Confirm a reset of checklists to default values, all checklist edits that have been made will be erased.")
        }
    }
    
    //MARK: - Navigation Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "categoryToAddArchiveInfo":
                archiveCategoryStorage.removeAll()
                for category in categories!.detached {
                    if category.selectedToArchive {
                        //store checklists that have been selected to be archived in a list as the user goes to add archive info, don't want to add to archive yet as the user could still cancel
                        let archiveCategory = CategoryArchive()
                        archiveCategory.title = category.title
                        archiveCategory.order = archiveCategoryStorage.count
                        archiveCategory.uniqueID = category.uniqueID
                        archiveCategory.items = category.items
                        archiveCategoryStorage.append(archiveCategory)
                    }
                }
                //set input fields for pilot name and drone model as last entry
                if let safeArchives = archive{
                    if safeArchives.count > 0 {
                        let destinationVC = segue.destination as! AddArchiveInfoViewController
                        destinationVC.lastNameInput = safeArchives[0].pilotName
                        destinationVC.lastDroneModelInput = safeArchives[0].droneModel
                    }
                }
                
                let destinationVC = segue.destination as! AddArchiveInfoViewController
                destinationVC.delegate = self
            case "categoryToAddEdit":
                let destinationVC = segue.destination as! AddEditViewController
                destinationVC.delegate = self
                destinationVC.selectedObjectText = indexPathNameSelected
                destinationVC.senderType = "Checklist"
            case "goToItems":
                let destinationVC = segue.destination as! ChecklistViewController
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.selectedCategory = categories?[indexPath.row]
                }
            
            default:
                print("error in segue")
            }
    }
}
