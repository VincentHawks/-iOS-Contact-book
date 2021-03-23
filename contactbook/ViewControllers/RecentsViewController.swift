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
    
    @objc func callMade(notification: Notification) {
        print("callMade")
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(callMade(notification:)), name: RecentsViewController.callMadeNotificationChannel, object: nil)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: RecentsViewController.callMadeNotificationChannel, object: nil)
    }

}
