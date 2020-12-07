//
//  Constants.swift
//  MobileiOS
//
//  Created by George on 28/10/2020.
//

import Foundation

struct Constants{
    
    static let nodeApi = "http://\(baseURL)/api/item"
    static let baseURL = "192.168.0.80:3000"
//    Localhost
//    static let baseURL = "127.0.0.1:3000"
    static let authApi = "http://\(baseURL)/api/auth/login"
    static let downloadLink = "https://raw.githubusercontent.com/georgemihoc/MobileiOS/main/tweets.json"
}
