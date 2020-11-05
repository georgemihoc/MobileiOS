//
//  DatabaseModels.swift
//  MobileiOS
//
//  Created by George on 05/11/2020.
//

import Foundation

struct Users: Codable {
    let users: [User]
}

struct User: Codable {
    let id: String
    let username: String
    let password: String
}
