//
//  RecentsViewController.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 22.03.2021.
//

import UIKit

struct Call {
    let timestamp: String
    let number: String
}

class RecentsViewController: UITableViewController {

    var contactList = [String : [Contact]]()
    var callHistory = [Call]()
    
    static let callMadeNotificationChannel = Notification.Name("callMade")
    
    // MARK: - Event handler
    
    @objc func callMade(notification: Notification) {
        guard let data = notification.userInfo as? [String : String],
              let number = data["number"]
        else {
            print("Failed to get call info")
            return
        }
        
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        let timestamp = "\(day).\(month).\(year) \(hour):\(minute)"
        let call = Call(timestamp: timestamp, number: number)
        callHistory.append(call)
        
        tableView.reloadData()
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(callMade(notification:)), name: RecentsViewController.callMadeNotificationChannel, object: nil)
    }

    // MARK: - Table view data source

    func passReference(toContactList list: inout [String : [Contact]]) {
        self.contactList = list
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callHistory.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! RecentViewCell

        // Configure the cell...
        let call = callHistory[callHistory.count - indexPath.row - 1] // Most recent shown first
        cell.number = call.number
        cell.detailTextLabel!.text = call.timestamp
        
        // There's probably a way to make this more efficient
        // Although if you think about it it's O(n), n = number of contacts, so not that bad
        if let text = contactList.values.first(where: { carr -> Bool in
            carr.contains(where: { c -> Bool in
                c.number == call.number
            })
        })?.first(where: { c -> Bool in
            c.number == call.number
        })?.name {
            cell.textLabel!.text = text
        } else {
            cell.textLabel!.text = call.number
        }

        return cell
    }
    
    // MARK: - Destructor
    deinit {
        NotificationCenter.default.removeObserver(self, name: RecentsViewController.callMadeNotificationChannel, object: nil)
    }

}
