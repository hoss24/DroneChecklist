//
//  AddEditViewController.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/24/21.
//

import UIKit
//delegate gets updated text for adding or replacing
protocol AddEditViewControllerDelegate{ //
    func addWithText(textInput addText: String)
    func updateWithText(textInput newText: String)
}

//view controller for adding or editing the checklist catergory name or checklist item name
class AddEditViewController: UIViewController, UITextViewDelegate {
    var delegate: AddEditViewControllerDelegate?
    var areEditing = false
    var selectedObjectText: String?
    var senderType = ""
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        textView.backgroundColor = K.AddTextViewBackgroundColor
        textView.becomeFirstResponder()
        view.backgroundColor = K.AddEditVCBackgroundColor

        if let text = selectedObjectText {
            if text != "" {
                textView.text = text
                areEditing = true
                navigationItem.title = "Edit " + senderType
                textView.accessibilityLabel = "Edit " + senderType
            }else{
                areEditing = false
                navigationItem.title = "Add "  + senderType
                textView.accessibilityLabel = "Add " + senderType
            }
        }
        checkText()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkText()
    }
    
    func checkText(){
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            navigationItem.rightBarButtonItem = nil
        } else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        }
    }

    // MARK: - Navigation
    @objc func saveTapped() {
        if let textInput = textView.text{
            if textInput != ""{
                if areEditing{
                    delegate?.updateWithText(textInput: textInput)
                }else{
                    delegate?.addWithText(textInput: textInput)
                }
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelTapped() {
        _ = navigationController?.popViewController(animated: true)
    }

}
