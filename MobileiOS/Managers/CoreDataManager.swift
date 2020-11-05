//
//  CoreDataManager.swift
//  MobileiOS
//
//  Created by George on 05/11/2020.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataContainer")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of store failed \(error)")
            }
        }
        
        return container
    }()
    
    @discardableResult
    func createUserDetails(username: String, password: String) ->  UserDetails? {
        let context = persistentContainer.viewContext
        
        let userDetails = NSEntityDescription.insertNewObject(forEntityName: "UserDetails", into: context) as! UserDetails
        
        userDetails.username = username
        userDetails.password = password
        
        do {
            try context.save()
            return userDetails
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func fetchUserDetails(withEmail email: String) -> UserDetails? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<UserDetails>(entityName: "UserDetails")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let user = try context.fetch(fetchRequest)
            return user.first
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
}
