//
//  DatabaseManager.swift
//  MobileiOS
//
//  Created by George on 05/11/2020.
//

import Foundation
import UIKit
import FirebaseStorage

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
}
