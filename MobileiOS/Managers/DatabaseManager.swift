//
//  DatabaseManager.swift
//  MobileiOS
//
//  Created by George on 05/11/2020.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore

struct Coordinates {
    let latitude: String
    let longitude: String
    let title: String
    let subtitle: String
}

class DatabaseManager {
    
    static let manager = DatabaseManager()
    
    let db = Firestore.firestore()
    
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
    
    func uploadItemPicture(image: UIImage, itemId: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let imagesRef = storageRef.child("images/items/\(itemId).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.9) {
            _ = imagesRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    if let error = error {
                        print(error)
                    }
                    return
                }
            }
        }
    }
    
    func deletePreviousPicture(itemId: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file to delete
        let deleteRef = storageRef.child("images/items/\(itemId).jpg")

        // Delete the file
        deleteRef.delete { error in
          if let error = error {
            print("Error at deleting the picture")
          } else {
            print("File deleted successfully")
          }
        }
    }
    
    //MARK: - Download
    func getItemPicture(itemId: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to download
        let pictureRef = storageRef.child("images/items/\(itemId).jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        pictureRef.getData(maxSize: 100 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            } else {
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                completion(.success(image))
            }
        }
    }
    
    func markItemLocation(itemId: String, latitude: String, longitude: String, title: String, subtitle: String) {
        // Add a new document in collection "cities"
        db.collection("locations").document("\(itemId)").setData([
            "latitude": latitude,
            "longitude": longitude,
            "title" : title,
            "subtitle" : subtitle
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func downloadItemLocation(itemId: String, completion: @escaping (Result<Coordinates, Error>) -> Void) {
        let docRef = db.collection("locations").document(itemId)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                if let latitude = document.data()?["latitude"] as? String, let longitude = document.data()?["longitude"] as? String, let title = document.data()?["title"] as? String, let subtitle = document.data()?["subtitle"] as? String {
                    completion(.success(Coordinates(latitude: latitude, longitude: longitude, title: title, subtitle: subtitle)))
                }
            } else {
                print("Document does not exist")
                if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }
}
