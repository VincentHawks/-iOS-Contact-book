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
    
    /// Catch every new character and introduce a whitespace for better formatting
    @IBAction func numberFieldEdited(_ sender: UITextField) {
        return
        guard let input = phoneField.text else {
            return
        }
        if(input.count == 0) {
            return
        }
        let adjustedLength = input[input.startIndex] == "+" ? input.count : input.count + 1
        var newString = ""
        // +7 999 123 45 67
        switch(adjustedLength) {
        case 2, 6, 10, 13:
            if input.count < prevPhoneLength {
                newString = input
                newString.removeLast()
            } else {
                newString = input + " "
            }
        case 3, 7, 11, 14:
            newString = input
            newString.removeLast()
        default:
            newString = input
        }
        prevPhoneLength = newString.count
        phoneField.text = newString
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
        print("Sent new contact")
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
