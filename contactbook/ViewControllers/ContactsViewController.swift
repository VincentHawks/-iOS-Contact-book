//
//  ContactsViewControllerTableViewController.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 22.03.2021.
//

import UIKit

class ContactsViewController: UITableViewController {

    var contactList = [String : [Contact]]()
    static let createContactNotificationCenter = Notification.Name("newContactNotification")
    static let deleteContactNotificationCenter = Notification.Name("deleteContactNotification")
    static let editContactNotificationCenter = Notification.Name("editContactNotification")
    
    @objc func newContact(notification: Notification) {
        guard let data = notification.userInfo as? [String : String],
              let name = data["name"],
              let number = data["number"]
        else {
            print("Failed to receive contact to create")
            return
        }
        
        let contact = Contact(name: name, number: number)
        let firstLetter = name.first!.uppercased()
        if contactList[firstLetter] == nil {
            contactList[firstLetter] = [Contact]()
        }
        if !contactList[firstLetter]!.contains(where: {(c) -> Bool in c.name == contact.name}) {
        contactList[firstLetter]!.append(contact)
        }
        
        tableView.reloadData()
        
        
        (tabBarController?.viewControllers?[1] as? RecentsViewController)?.passReference(toContactList: &contactList)
    }
    
    @objc func editContact(notification: Notification) {
        guard let data = notification.userInfo as? [String : String],
              let name = data["name"],
              let number = data["number"],
              let oldName = data["oldName"]
        else {
            print("Failed to receive contact to edit")
            return
        }
        
        let oldFirstLetter = oldName.first!.uppercased()
        guard (contactList[oldFirstLetter] != nil) else {
            fatalError("Illegal contact list state")
        }
        guard let oldContactIndex: Int = contactList[oldFirstLetter]!.firstIndex(where: {
            (c) -> Bool in
            c.name == oldName
        }) else {
            return
        }
        contactList[oldFirstLetter]!.remove(at: oldContactIndex)
        if contactList[oldFirstLetter]!.isEmpty {
            contactList.remove(at: contactList.index(forKey: oldFirstLetter)!)
        }
        
        let newFirstLetter = name.first!.uppercased()
        if contactList[newFirstLetter] == nil {
            contactList[newFirstLetter] = [Contact]()
        }
        if !contactList[newFirstLetter]!.contains(where: {(c) -> Bool in c.name == name}) {
            contactList[newFirstLetter]?.append(Contact(name: name, number: number))
        }
        
        tableView.reloadData()
        
        (tabBarController?.viewControllers?[1] as? RecentsViewController)?.passReference(toContactList: &contactList)
    }
    
    @objc func deleteContact(notification: Notification) {
        guard let data = notification.userInfo as? [String : String],
              let name = data["name"],
              let number = data["number"]
        else {
            print("Failed to receive contact to delete")
            return
        }
        
        let firstLetter = name.first!.uppercased()
        contactList[firstLetter]?.removeAll { (c) -> Bool in
            c.name == name && c.number == number
        }
        if contactList[firstLetter]!.isEmpty {
            contactList.remove(at: contactList.index(forKey: firstLetter)!)
        }
        
        tableView.reloadData()
        
        (tabBarController?.viewControllers?[1] as? RecentsViewController)?.passReference(toContactList: &contactList)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print()
        NotificationCenter.default.addObserver(self, selector: #selector(newContact(notification:)), name: ContactsViewController.createContactNotificationCenter, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteContact(notification:)), name: ContactsViewController.deleteContactNotificationCenter, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(editContact(notification:)), name: ContactsViewController.editContactNotificationCenter, object: nil)

        tableView.dataSource = self
        tableView.delegate = self
        
        contactList["J"] = [Contact(name: "John Doe", number: "88005553535")]
        contactList["E"] = [Contact(name: "Emergency", number: "112")]
        tableView.reloadData()
        
        tabBarController?.viewControllers?[1].view // make it instantiated
        // Pass a reference to the contact list for the Recents screen to use (failed)
        (tabBarController?.viewControllers?[1] as? RecentsViewController)?.passReference(toContactList: &contactList)
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func getContact(fromIndexPath indexPath: IndexPath) -> Contact {
        let contactKey = contactList.keys.sorted()[indexPath.section]
        let contactSection = contactList[contactKey]!
        let contact = contactSection[indexPath.row]
        return contact
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        contactList.count
    }

    /// This assumes that the section number provided is the index in a sorted array of keys of the contact list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Always assume the section number as index in the sorted keys array
        contactList[contactList.keys.sorted()[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        contactList.keys.sorted()[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell

        // Configure the cell...
        let contactKey = contactList.keys.sorted()[indexPath.section]
        guard let contactsSection = contactList[contactKey] else {
            fatalError("Illegal state")
        }
        let contact = contactsSection[indexPath.row]
        cell.contact = contact
        cell.textLabel!.text = contact.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = getContact(fromIndexPath: indexPath)
        NotificationCenter.default.post(name: RecentsViewController.callMadeNotificationChannel, object: self, userInfo: ["number" : contact.number])
        print("Making a call...")
        guard let url = URL(string: "tel://" + contact.number) else { return }
        guard UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? ContactInfoViewController,
           let cell = sender as? ContactCell,
           let contact = cell.contact {
            dest.name = contact.name
            dest.number = contact.number
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ContactsViewController.createContactNotificationCenter, object: nil)
        NotificationCenter.default.removeObserver(self, name: ContactsViewController.editContactNotificationCenter, object: nil)
        NotificationCenter.default.removeObserver(self, name: ContactsViewController.deleteContactNotificationCenter, object: nil)
    }
}
