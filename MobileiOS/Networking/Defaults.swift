//
//  Defaults.swift
//  NetworkingTask
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import Foundation

class Defaults {
    
    static let manager = Defaults()
    
    private init() {}
    
    static func store(_ items: [Item]) {
        let defaults = UserDefaults.standard
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(items)
            defaults.set(data, forKey: "items")
        } catch {
            print(error)
        }
    }
    
    static func append(_ item: Item) {
        let defaults = UserDefaults.standard
        
        let encoder = JSONEncoder()
        
        do {
            var currentDefaultsItems = get()
            currentDefaultsItems?.append(item)
            let data = try encoder.encode(currentDefaultsItems)
            defaults.set(data, forKey: "items")
        } catch {
            print(error)
        }
    }
    
    static func get() -> [Item]? {
        
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: "items")
        
        let decoder = JSONDecoder()

        guard let itemsData = data else {
            return nil
        }
        
        do {
            let items = try decoder.decode([Item].self, from: itemsData)
            return items
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
