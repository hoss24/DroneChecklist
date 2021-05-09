//
//  InstructionViewController.swift
//  Drone Checklist
//
//  Created by Grant Matthias Hosticka on 3/19/21.
//

import UIKit

//View Controller for user guide page of app
class InstructionViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = true
        navigationItem.title = "User Guide"
        textView.isEditable = false
        textView.isSelectable = false
        addUITextView()
    }
    
    func addUITextView(){
        //Create text attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body)
            ]
        let title2Attribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .title2)
            ]

        //Add text and images
        let myString = NSMutableAttributedString(string:
        """
        Thanks for using Drone Checklist. \n
        """, attributes: title2Attribute)
        
        myString.append(NSMutableAttributedString(string:
        """
        - The default checklists have been created from the FAA AC 107-2A Sample Preflight Assessment and Inspection Checklist.
        - AC 107-2A states that: "Remote pilots may choose to use this checklist or develop their own for the operation of their specific small UAS."
        """, attributes: attributes))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n
        Drone Checklist Functions: \n
        """, attributes: title2Attribute))
        
        myString.append(NSMutableAttributedString(string:
        """
        - Create and modify checklists to help increase safety and efficiency of drone operations.
        - Archive completed checklists with additional operational data for a saved record of completing the checklist and the ability to use the in-app checklist(s) again.
        - Export archived data to a .csv file for modification, data backup, or reporting needs. \n \n
        """, attributes: attributes))
        
        myString.append(NSMutableAttributedString(string:
        """
        Checklists: \n
        """, attributes: title2Attribute))
        
        myString.append(NSMutableAttributedString(string:
        """
        - The application includes defaults checklists that can be deleted or modified.\n \n
        """, attributes: attributes))
        
        myString.append(createImage("guide1"))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n
        \n
        """, attributes: attributes))
        
        myString.append(createImage("guide2"))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n
        \n
        """, attributes: attributes))
        
        myString.append(createImage("guide3"))
        
        myString.append(NSAttributedString(string:
        """
        \n
        Add:
        - Tap the plus button in the bottom center to add new checklists or checklist items.

        Delete:
        - Swipe left on checklist/checklist item or tap on edit in the top right then tap the delete message to confirm deletion. To exit the edit status tap done.

        Reorder:
        - Tap on edit in the top right and tap and drag on the right side of the checklist category/checklist item where three lines are displayed. To exit the edit status tap done.

        Reset Checklists:
        - Tap on Reset Lists in the bottom left to reset all checklists to default values. All checklist edits that have ben made will be erased and replaced.

        View Checklist Items:
        - Tap on a checklist category to view the items that are a part of the checklist.

        Check/Uncheck:
        - Tap on a checklist item to toggle between checked and unchecked.
        - **When all checklist items have been checked, the checklist category text will become bold, italicized, and green. \n \n
        """, attributes: attributes))


        myString.append(NSMutableAttributedString(string:
        """
        Archive: \n
        """, attributes: title2Attribute))
        
        myString.append(NSMutableAttributedString(string:
        """
        - Archive checklists and add additional operational data.
        - Date will be saved to local device and can later be exported to a .csv \n \n
        """, attributes: attributes))

        myString.append(createImage("guide4"))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n
        \n
        """, attributes: attributes))
        
        myString.append(createImage("guide5"))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n
        \n
        """, attributes: attributes))
        
        myString.append(createImage("guide6"))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n \n
        """, attributes: attributes))
        
        myString.append(createImage("guide7"))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n
        Select Checklists to Archive:
        - Within the main checklist view tap archive data in the bottom right, select the checklist(s) to archive, and then tap next in the top right.
        - **Selecting checklists is optional. If no checklists are selected, "next" can still be tapped to archive operational data such as flight time and location.
        
        Add Operational Data:
        - The next screen allows the addition of optional operational data such as date/time lat/long and flight time. After data has been input, tap on the bottom bar to finish and archive data.
        - After data has been archived selected checklists will be reset to all items being unchecked.  \n \n
        """, attributes: attributes))

        myString.append(NSMutableAttributedString(string:
        """
        Export: \n
        """, attributes: title2Attribute))
        
        myString.append(NSMutableAttributedString(string:
        """
        - Export archived data to a .csv file. \n \n
        """, attributes: attributes))

        myString.append(createImage("guide8"))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n
        \n
        """, attributes: attributes))
        
        myString.append(createImage("guide9"))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n
        \n
        """, attributes: attributes))
        
        myString.append(createImage("guide10"))
        
        myString.append(NSMutableAttributedString(string:
        """
        \n
        View Archived Data:
        - From the home screen select the Archived Data option.
        - Archived data is sorted with the newest archive being displayed first.
        - Can tap on a row of archived data to see all information.
        
        Delete Archived Data:
        - Swipe left on a cell to delete the archive entry or tap select in the top right and the tap the trash icon in the bottom right.
        
        Select Data to Export:
        - To export data tap select in the top right and select archived data to include.

        Export Data to CSV:
        - After completion tap on the export icon in the bottom left and options will be displayed including AirDrop, applications, and email.
        - **If opening the .csv file within the iOS device files app the checklist information will all be on one row, however if using a program such as Google Sheets or Numbers the checklist data cell will be properly formatted with multiple lines. \n \n \n
        """, attributes: attributes))
        
        myString.append(NSMutableAttributedString(string:
        """
        Application Attributions: \n
        """, attributes: title2Attribute))
        
        myString.append(NSMutableAttributedString(string:
        """
        - Drone Checklist was developed by Grant Hosticka as a tool to help fellow pilots.
        - The app is open source and can be found at https://github.com/hoss24. Pull requests are encouraged.
        - Icons made by Freepik, and Pixel perfect from www.flaticon.com.
        - Additional icons made by Google.
        """, attributes: attributes))
        
        // set the text for the UITextView on screen
        textView.attributedText = myString;
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = K.BarTextColor
        }
    
    
    func createImage(_ imageName: String)-> NSAttributedString{
        //set image size, check if device is an iPad to scale image
        var height = self.view.frame.size.height
        //check if iPad
        if height > 896{
            height -= 450
        }
        else{
            height -= 250
        }
        let width = self.view.frame.size.width - 100
        let targetSize = CGSize(width: width, height: height)

        // create imageView
        let imageView = UIImageView()
        // set image from input
        imageView.image = UIImage(named: imageName)
        // create imageAttachment
        let imageAttachment = NSTextAttachment()
        //set attachemtn image and resize
        imageAttachment.image = imageView.image?.scalePreservingAspectRatio(targetSize)
        imageAttachment.accessibilityLabel = "App screenshot. Image"
        // wrap the attachment in its own attributed string so we can append it
        let imageString = NSAttributedString(attachment: imageAttachment)
        return imageString
    }
}

//extension to resize image
extension UIImage {
    func scalePreservingAspectRatio(_ targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        return scaledImage
    }
}



