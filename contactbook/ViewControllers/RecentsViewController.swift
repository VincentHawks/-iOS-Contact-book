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
    var name: String?
}

class RecentsViewController: UITableViewController {

    var callHistory = [Call]()
    
    // MARK: - Update notification callbacks
    
    func callMade(number: String, name: String) {
        let date = Date()
        let calendar = Calendar.current
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        let hh = calendar.component(.hour, from: date)
        let mm = calendar.component(.minute, from: date)
        let timestamp = String(format: "%02d.%02d.%04d %02d:%02d", d, m, y, hh, mm)
        callHistory.append(Call(timestamp: timestamp, number: number, name: name))
        tableView.reloadData()
    }
    
    /// Checks if new contact's number had been dialed previously and renames it accordingly
    func contactAdded(name: String, number: String) {
        if callHistory.isEmpty {
            return
        }
        for i in 0..<callHistory.count {
            if callHistory[i].number == number {
                callHistory[i].name = name
            }
        }
        tableView.reloadData()
    }
    
    /// Acts as if the old one was removed and the new one was created
    func contactAltered(oldName: String, newName: String, newNumber: String) {
        if callHistory.isEmpty {
            return
        }
        for i in 1..<callHistory.count {
            if callHistory[i].name == oldName {
                callHistory[i].name = nil
            }
        }
        for i in 1..<callHistory.count {
            if callHistory[i].number == newNumber {
                callHistory[i].name = newName
            }
        }
        tableView.reloadData()
    }
    
    /// Remove the name from the call records of the deleted contact, making the number be displayed instead of the name
    func contactRemoved(name: String, number: String) {
        if callHistory.isEmpty {
            return
        }
        for i in 1..<callHistory.count {
            if callHistory[i].name == name && callHistory[i].number == number {
                callHistory[i].name = nil
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Table view data source
    
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
        cell.detailTextLabel!.text = call.timestamp
        
        if call.name != nil {
            cell.textLabel?.text = call.name
        } else {
            cell.textLabel?.text = call.number
        }

        return cell
    }

}
