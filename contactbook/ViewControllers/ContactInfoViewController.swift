//
//  ContactInfoViewController.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 22.03.2021.
//

import UIKit

class ContactInfoViewController: UIViewController {
    
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    var name: String = ""
    var number: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(editingDone), name: ContactsViewController.editContactNotificationCenter, object: nil)
        
        phoneLabel.text = number
        nameLabel.text = name
    }
    
    @objc func editingDone() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: ContactsViewController.deleteContactNotificationCenter, object: self, userInfo: ["name":nameLabel.text!, "number":phoneLabel.text!])
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? EditContactViewController {
            dest.oldName = name
            dest.oldNumber = number
        }
    }

}
