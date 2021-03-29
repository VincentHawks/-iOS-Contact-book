//
//  ContactsViewControllerTableViewController.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 22.03.2021.
//

import UIKit
import Dispatch

enum ParallelismMode {
    case gcd
    case opqueue
}

class ContactsViewController: UITableViewController {

    var contactList: [String : [Contact]] = [:]
    var recents: RecentsViewController?
    static let createContactNotificationCenter = Notification.Name("newContactNotification")
    static let deleteContactNotificationCenter = Notification.Name("deleteContactNotification")
    static let editContactNotificationCenter = Notification.Name("editContactNotification")
    
    // MARK: - Contact list fetch
    
    func fetchGCD() {
        let repository = GistContactRepository(path: "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json")
        let queue = DispatchQueue(label: "DownloaderQueue", qos: .utility)
        var updatedContacts = [String : [Contact]]()
        queue.async {
            let gistContacts = try! repository.getContacts()
            for gistContact in gistContacts {
                let contact = Contact(name: "\(gistContact.firstName) \(gistContact.lastName)", number: gistContact.phone)
                guard let firstLetter = contact.name.first else {
                    continue
                }
                if updatedContacts[firstLetter.uppercased()] == nil {
                    updatedContacts[firstLetter.uppercased()] = [contact]
                } else {
                    updatedContacts[firstLetter.uppercased()]?.append(contact)
                }
            }
        }
        contactList = updatedContacts
    }
    
    func fetchOpQueue() {
        let repository = GistContactRepository(path: "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json")
        
        let queue = OperationQueue()
        queue.name = "Downloader queue"
        queue.maxConcurrentOperationCount = 1
        
        let downloader = DownloadOperation(repo: repository)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            if !downloader.success {
                print("Failed to fetch contact data")
                return
            }
            DispatchQueue.main.async { 
                self.contactList = downloader.digestedContacts
                self.tableView.reloadData()
            }
        }
        queue.addOperation(downloader)
    }
    
    // MARK: - Event handlers
    
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
        recents!.contactAdded(name: name, number: number)
        tableView.reloadData()
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
        recents!.contactAltered(oldName: oldName, newName: name, newNumber: number)
        tableView.reloadData()
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
        recents!.contactRemoved(name: name, number: number)
        tableView.reloadData()
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(newContact(notification:)), name: ContactsViewController.createContactNotificationCenter, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteContact(notification:)), name: ContactsViewController.deleteContactNotificationCenter, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(editContact(notification:)), name: ContactsViewController.editContactNotificationCenter, object: nil)

        tableView.dataSource = self
        tableView.delegate = self
        
        recents = tabBarController?.viewControllers?[1] as? RecentsViewController
        _ = recents!.view // make it instantiated
        
        // Fetch contacts data from web
        switch GlobalDefinitions.parallelismMode {
        case .gcd:
            fetchGCD()
        case .opqueue:
            fetchOpQueue()
        }
        
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
        let contact = getContact(fromIndexPath: indexPath)
        cell.textLabel!.text = contact.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = getContact(fromIndexPath: indexPath)
        recents!.callMade(number: contact.number, name: contact.name)
        guard let url = URL(string: "tel://" + contact.number) else { return }
        guard UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }

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
    
    // MARK: - Destructor
    deinit {
        NotificationCenter.default.removeObserver(self, name: ContactsViewController.createContactNotificationCenter, object: nil)
        NotificationCenter.default.removeObserver(self, name: ContactsViewController.editContactNotificationCenter, object: nil)
        NotificationCenter.default.removeObserver(self, name: ContactsViewController.deleteContactNotificationCenter, object: nil)
    }
}
