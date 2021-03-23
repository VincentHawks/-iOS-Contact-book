//
//  EditContactViewController.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 23.03.2021.
//

import UIKit

class EditContactViewController: UIViewController {

    var oldName = ""
    var oldNumber = ""
    @IBOutlet var nameField: UITextField!
    @IBOutlet var phoneField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.text = oldName
        phoneField.text = oldNumber
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        if nameField.text == oldName && phoneField.text == oldNumber {
            return
        }
        
        if nameField.text != "" && phoneField.text != "" {
            NotificationCenter.default.post(name: ContactsViewController.editContactNotificationCenter, object: self, userInfo: [
                "name" : nameField.text!,
                "number" : phoneField.text!,
                "oldName": oldName
            ])
            navigationController?.popViewController(animated: false)
        }
    }

}
