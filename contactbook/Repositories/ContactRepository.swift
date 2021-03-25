//
//  ContactRepository.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 25.03.2021.
//

import Foundation
import Dispatch

struct GistContact : Codable {
    var firstname: String
    var lastname: String
    var phone: String
    var email: String
}

protocol ContactRepository {
    func getContacts() throws -> [GistContact]
}

class RequestFailed : Error {}

class GistContactRepository : ContactRepository {
    
    private let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func getContacts() throws -> [GistContact] {
        
        let sem = DispatchSemaphore(value: 0)
        
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        var result: [GistContact] = []
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            defer {
                sem.signal()
            }
            // TODO: handle error
            do {
                guard let data = data, error == nil else {
                    throw error ?? RequestFailed()
                }
                // TODO: parse data
                result = try JSONDecoder().decode([GistContact].self, from: data)
            } catch {
                print("Request failed")
            }
        }
        task.resume()
        // TODO: add timeout
        _ = sem.wait(timeout: .now() + .seconds(10))
        return result
        
    }
    
}
