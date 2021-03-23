//
//  NewContactViewController.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 22.03.2021.
//

import UIKit

class NewContactViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    var prevPhoneLength = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let name = nameField.text else { return }
        guard let rawPhone = phoneField.text else { return }
        
        if name == "" || rawPhone == "" {
            return
        }
        
        var treatedPhone = rawPhone
        treatedPhone.removeAll { (c) -> Bool in
            !(c.isNumber || c == "+")
        }
        
        NotificationCenter.default.post(name: ContactsViewController.createContactNotificationCenter, object: self, userInfo: ["name": name, "number": treatedPhone])
        navigationController?.popViewController(animated: true)
    }

}
