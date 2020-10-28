//
//  Networking.swift
//  NetworkingTask
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import Foundation
import Alamofire

struct Tweets: Codable {
    let tweets: [Tweet]
}

struct Tweet: Codable {
    let from: String
    let handler: String
    let message: String
    let timestamp: String
}

struct Items: Codable {
    let items: [Item]
}

struct Item: Codable {
    let date: String
    let id: String
    let text: String
    let version: Int
}

class Networking {
    
    static let downloadLink = "https://raw.githubusercontent.com/georgemihoc/MobileiOS/main/tweets.json"
    static let nodeAPI = "http://127.0.0.1:3000/item"
    
    static func download(completion: @escaping ([Item]) -> Void) {
        
        AF.request(Constants.nodeApi, method: .get).responseJSON { response in
            if let data = response.data {
                do {
                    let itemsArray = try JSONDecoder().decode([Item].self, from: data)
                    completion(itemsArray)
                } catch {
                    print(error)
                }
            }
        }
    }
}
