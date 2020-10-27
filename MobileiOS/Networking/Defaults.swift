//
//  Defaults.swift
//  NetworkingTask
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import Foundation

struct Constants {
    static let key = "tweets"
}

class Defaults {
    
    static func store(_ colors: [Tweet]) {
        let defaults = UserDefaults.standard
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(colors)
            defaults.set(data, forKey: Constants.key)
        } catch {
            print(error)
        }
    }
    
    static func get() -> [Tweet]? {
        
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: Constants.key)
        
        let decoder = JSONDecoder()

        guard let tweetsData = data else {
            return nil
        }
        
        do {
            let tweets = try decoder.decode([Tweet].self, from: tweetsData)
            return tweets
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
