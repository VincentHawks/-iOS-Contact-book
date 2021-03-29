//
//  DownloadOperation.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 25.03.2021.
//

import Foundation

class DownloadOperation : Operation {
    
    let repository: ContactRepository
    var digestedContacts: [String : [Contact]] = [:]
    var success: Bool = true

    init(repo: ContactRepository) {
        self.repository = repo
    }
    
    override func main() {
        if isCancelled {
            return
        }
        let gistContacts: [GistContact]
        do {
            gistContacts = try repository.getContacts()
        } catch {
            success = false
            return
        }
        
        for gistContact in gistContacts {
            let contact = Contact(name: "\(gistContact.firstName) \(gistContact.lastName)", number: gistContact.phone)
            guard let firstLetter = contact.name.first else {
                continue
            }
            if digestedContacts[firstLetter.uppercased()] == nil {
                digestedContacts[firstLetter.uppercased()] = [contact]
            } else {
                digestedContacts[firstLetter.uppercased()]!.append(contact)
            }
        }
    }
    
}
