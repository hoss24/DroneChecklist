//
//  SwipeTableViewController.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/19/21.
//

import UIKit

//class for default table view properties other controllers will inherit
class SwipeTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableViewProperties
        tableView.estimatedRowHeight =  270
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelectionDuringEditing = true
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) //as! SwipeTableViewCell
        let cellBGView = UIView()
        cellBGView.backgroundColor = K.cellClickedColor
        cell.selectedBackgroundView = cellBGView
        cell.textLabel?.numberOfLines = 0 //allows row size to expand
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }

    
}

