//
//  ChecklistViewController.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/19/21.
//

import UIKit
import RealmSwift


class ChecklistViewController: SwipeTableViewController, AddEditViewControllerDelegate{
    //initalize new Realm
    let realm = try! Realm()
    var checklistItems: Results<Item>?
    var selectedCategory: Category?
    var indexPathNameSelected = ""
    var itemToEdit: Item?

    
    override func viewWillAppear(_ animated: Bool) {
        loadItems()
        createBars()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedCategory?.title
    }
    
    //MARK: - Toolbar
    func createBars(){
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        add.accessibilityLabel = "Add new item to checklist"
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let edit = editButtonItem
        let uncheck = UIBarButtonItem(title: "Uncheck All", style: .plain, target: self, action: #selector(uncheckAllTapped))
        //bar button for spacing
        let spacer2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        spacer2.width = uncheck.width
        
        if !tableView.visibleCells.isEmpty {
            navigationItem.rightBarButtonItem = edit
        }
        else{
            navigationItem.rightBarButtonItem = nil
        }
        if isEditing{
            setToolbarItems([spacer, add, spacer], animated: false)
            navigationItem.setHidesBackButton(true, animated: true)
        }
        else{
            setToolbarItems([spacer2, spacer, add, spacer, uncheck], animated: false)
            navigationItem.setHidesBackButton(false, animated: true)
        }
        navigationController?.setToolbarHidden(false, animated: false)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklistItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tap into cell that gets created inside superclass at indexPath
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = checklistItems![indexPath.row].instructions
        
        if checklistItems![indexPath.row].done && isEditing == false{
            cell.accessibilityLabel = "Completed. " + checklistItems![indexPath.row].instructions + ". Double tap to mark as incomplete"
        } else if checklistItems![indexPath.row].done == false && isEditing == false {
            cell.accessibilityLabel = "Incomplete. " + checklistItems![indexPath.row].instructions + ". Double tap to mark as completed"
        } else {
            cell.accessibilityLabel = checklistItems![indexPath.row].instructions
        }
        
        //create custom accessory for cell
        let cellCheckButton = UIButton(type: .custom)
        cellCheckButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        cellCheckButton.isUserInteractionEnabled = false
        cellCheckButton.contentMode = .scaleAspectFit
        cellCheckButton.isAccessibilityElement = false
        //set image based on checklist item done state
        if checklistItems![indexPath.row].done {
            cellCheckButton.setImage(UIImage(named: "check-box"), for: .normal)
            cellCheckButton.accessibilityLabel = "Checkbox with checkmark"
        } else{
            cellCheckButton.setImage(UIImage(named: "blank-check-box"), for: .normal)
            cellCheckButton.accessibilityLabel = "Checkbox without checkmark"
        }
        cell.accessoryView = cellCheckButton as UIView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //MARK: - Data Manipulation Methods
    //MARK: - Load Data
    func loadItems() {
        //start auto updating categories
        checklistItems = selectedCategory?.items.sorted(byKeyPath: "order", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Add Data
    func addWithText(textInput addText: String) {
        let newItem = Item()
        newItem.instructions = addText
        newItem.order = checklistItems?.count ?? 0
        //save updated array and reload view
        save(item: newItem)
    }
    
    //MARK: - Save Data
    func save(item: Item) {
        if let currentCategory = selectedCategory{
            do {
                try realm.write {
                    currentCategory.items.append(item)
                }
            } catch {
                print("Error saving context: \(error)")
            }
        }
        //reload to take into account new item in array
        //insert row instead of reloading all tableview data
        let indexPath = IndexPath(row: ((checklistItems?.count ?? 1) - 1), section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: - Move Data Order
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = checklistItems![sourceIndexPath.row]  //store item that has been moved before editing
        for item in checklistItems! {
            //item current order
            let itemOrder = item.order
            if destinationIndexPath.row < sourceIndexPath.row{ //if item moved to lower index path number
                // anything greater than or equal to destination and less than source plus one
                if itemOrder >= destinationIndexPath.row && itemOrder < sourceIndexPath.row{
                    //add one to order
                    let newOrder = itemOrder + 1
                    updateItemOrder(item: item, newOrder: newOrder)
                }
            }else{ //if item moved to higher index path number
                // anything less than or equal to destination and greater than source minus one
                if itemOrder <= destinationIndexPath.row && itemOrder > sourceIndexPath.row{
                    //subtract one from order
                    let newOrder = itemOrder - 1
                    updateItemOrder(item: item, newOrder: newOrder)
                }
            }
        }
        //edit item order that was moved
        updateItemOrder(item: itemToMove, newOrder: destinationIndexPath.row)
        loadItems()
    }
    //MARK: - Update Data
    func updateItemOrder (item: Item, newOrder: Int){
        do {
            try realm.write {
                item.order = newOrder
            }
        } catch {
            print("error editing item \(error)")
        }
    }
    
    func updateWithText (textInput newText: String){
        do {
            try realm.write {
                itemToEdit!.instructions = newText
            }
        } catch {
            print("error editing item \(error)")
        }
        //reload to take into account new item in array
        self.tableView.reloadData()
    }
    
    @objc func updateCheckmark (indexPathRow: Int){
        if let item = checklistItems?[indexPathRow] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("error saving done status \(error)")
            }
        }
        tableView.reloadData()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight =  270
    }
    
    //MARK: - Delete Data
    func updateModel(at indexPath: IndexPath) {
        //store item that has been moved before editing
        let itemToDelete = checklistItems![indexPath.row]
        if checklistItems!.count > 1 {
            for item in checklistItems! {
                let itemOrder = item.order
                if itemOrder > indexPath.row {
                    let newOrder = itemOrder - 1
                    updateItemOrder(item: item, newOrder: newOrder)
                }
            }
        }
        // handle action by updating model with deletion
        do {
            try realm.write {
                realm.delete(itemToDelete)
            }
        } catch {
            print("error deleting item \(error)")
        }
        tableView.reloadData()
        createBars()
    }
    
    //MARK: - TableView Delegate Methods
    //what happens when a tap occurs
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //
        if self.isEditing {
            self.goToEditItem(indexPath)
        }
        else{
            self.updateCheckmark(indexPathRow: indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            updateModel(at: indexPath)
            loadItems()
         }
    }
    
    //MARK: - Toolbar Button Methods
    @objc func addTapped(){
        indexPathNameSelected = ""
        performSegue(withIdentifier: "checklistToAddEdit" , sender: indexPathNameSelected)
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)

        // Toggle table view editing.
        tableView.setEditing(editing, animated: true)
        
        if isEditing{
            navigationItem.title = "Editing"
        }else{
            navigationItem.title = selectedCategory?.title
        }
        if isEditing == false{
            tableView.reloadData()
        }
        createBars()
    }
    
    @objc func uncheckAllTapped(){
        if let items = checklistItems{
            for item in items {
                do {
                    try realm.write {
                        item.done = false
                    }
                } catch {
                    print("error saving done status \(error)")
                }
            }
        }
        tableView.reloadData()
    }
    
    //MARK: - Navigation Methods
    func goToEditItem(_ indexPath: IndexPath) {
        itemToEdit = checklistItems![indexPath.row]
        indexPathNameSelected = checklistItems![indexPath.row].instructions
        performSegue(withIdentifier: "checklistToAddEdit" , sender: indexPathNameSelected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "checklistToAddEdit":
                let destinationVC = segue.destination as! AddEditViewController
                destinationVC.delegate = self
                destinationVC.selectedObjectText = indexPathNameSelected
                destinationVC.senderType = "Checklist Item"
            default:
                print("error in segue")
            }
    }
    
}

