//
//  DatabaseManager.swift
//  MobileiOS
//
//  Created by George on 05/11/2020.
//

import Foundation

class DatabaseManager {
    
    static let manager = DatabaseManager()
    
    func loadJson() -> Users? {
       let decoder = JSONDecoder()
       guard
        let url = Bundle.main.url(forResource: "users", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let users = try? decoder.decode(Users.self, from: data)
       else {
            return nil
       }

       return users
    }
}
