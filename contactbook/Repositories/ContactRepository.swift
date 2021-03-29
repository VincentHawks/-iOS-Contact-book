//
//  ContactRepository.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 25.03.2021.
//

import Foundation
import Dispatch

struct GistContact : Codable {
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "firstname"
        case lastName = "lastname"
        case phone
        case email
    }
}

protocol ContactRepository {
    func getContacts() throws -> [GistContact]
}

class RequestFailed : Error {}
class RequestTimeout : Error {}

class GistContactRepository : ContactRepository {
    
    private let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func getContacts() throws -> [GistContact] {
        
        let sem = DispatchSemaphore(value: 0)
        
        let url = URL(string: path)
        let request = URLRequest(url: url!)
        var result = [GistContact]()
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            defer {
                sem.signal()
            }
            do {
                guard let data = data, error == nil else {
                    throw error ?? RequestFailed()
                }
                result = try JSONDecoder().decode([GistContact].self, from: data)
            } catch {
                print("Request failed")
            }
        }
        task.resume()
        let timeoutResult = sem.wait(timeout: .now() + .seconds(20))
        switch timeoutResult {
        case .success:
            return result
        case .timedOut:
            print("Request timeout")
            throw RequestTimeout()
        }
    }
}
