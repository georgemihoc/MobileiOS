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
    
    func storeToken(token: String) {
        let defaults = UserDefaults.standard
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(token)
            defaults.set(data, forKey: "userToken")
        } catch {
            print(error)
        }
    }
    
    func getCurrentToken() -> String {
        
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: "userToken")
        
        let decoder = JSONDecoder()

        guard let notesData = data else {
            return ""
        }
        
        do {
            let notes = try decoder.decode(String.self, from: notesData)
            return notes
        } catch {
            print(error.localizedDescription)
        }
        
        return ""
    }
    
    static func store(_ notes: [Note]) {
        let defaults = UserDefaults.standard
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(notes)
            defaults.set(data, forKey: "notes")
        } catch {
            print(error)
        }
    }
    
    static func append(_ note: Note) {
        let defaults = UserDefaults.standard
        
        let encoder = JSONEncoder()
        
        do {
            var currentDefaultsItems = get()
            currentDefaultsItems?.append(note)
            let data = try encoder.encode(currentDefaultsItems)
            defaults.set(data, forKey: "notes")
        } catch {
            print(error)
        }
    }
    
    static func get() -> [Note]? {
        
        let defaults = UserDefaults.standard
        let data = defaults.data(forKey: "notes")
        
        let decoder = JSONDecoder()

        guard let notesData = data else {
            return nil
        }
        
        do {
            let notes = try decoder.decode([Note].self, from: notesData)
            return notes
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key != "userToken"{
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    func resetToken() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key == "userToken"{
                defaults.removeObject(forKey: key)
            }
        }
    }
}
