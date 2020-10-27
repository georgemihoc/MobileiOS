//
//  Networking.swift
//  NetworkingTask
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import Foundation

struct Tweets: Codable {
    let tweets: [Tweet]
}

struct Tweet: Codable {
    let from: String
    let handler: String
    let message: String
    let timestamp: String
}

class Networking {
    
    static let downloadLink = "https://raw.githubusercontent.com/georgemihoc/MobileiOS/main/tweets.json"
    
    static func download(completion: @escaping ([Tweet]) -> Void) {
        if let url = URL(string: downloadLink) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let tweetsArray = try JSONDecoder().decode(Tweets.self, from: data)
                        completion(tweetsArray.tweets)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
}
