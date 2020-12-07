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

struct Note: Codable {
    let text: String
    let userId: String
    let _id: String
    var completed: Bool
}

struct OfflineNote: Codable {
    let text: String
}

class Networking {
    
    static let shared = Networking()
    
     func download(completion: @escaping ([Note]) -> Void) {
        
        let headers: HTTPHeaders = [
           "Authorization": "Bearer \(Defaults.manager.getCurrentToken())",
           "Content-Type": "application/json"
       ]
        
        AF.request(Constants.nodeApi, method: .get, headers: headers).response { response in
            if response.error != nil {
                AlertManager.manager.showDisconnectedBannerNotification(title: "Network Error", message: "Could not fetch data", duration: 1)
                return
            }
            if let data = response.data {
                do {
                    let itemsArray = try JSONDecoder().decode([Note].self, from: data)
                    completion(itemsArray)
                } catch {
                    print(error)
                }
            }
        }
        
    }
    
     func createItem(text: String) {
        
        let headers: HTTPHeaders = [
           "Authorization": "Bearer \(Defaults.manager.getCurrentToken())",
           "Content-Type": "application/json"
       ]
                
        let parameters: [String : Any] =
            ["text" : text]
       
        AF.request(Constants.nodeApi, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.error != nil {
                Defaults.manager.appendOfflineNote(OfflineNote(text: text))
                AlertManager.manager.showDisconnectedBannerNotification(title: "Error", message: "Could not add item, will try again when online", duration: 1)
                return
            }
        }
    }
    
    func uploadOfflineAddedItems(items: [OfflineNote]) {
        let headers: HTTPHeaders = [
           "Authorization": "Bearer \(Defaults.manager.getCurrentToken())",
           "Content-Type": "application/json"
       ]
                
        print(items.count)
        for item in items {
            print(item.text)
            let parameters: [String : Any] =
                ["text" : item.text]
           
            AF.request(Constants.nodeApi, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.error != nil {
                    AlertManager.manager.showDisconnectedBannerNotification(title: "Error", message: "Could not add item", duration: 1)
                    return
                }
            }
        }
        
    }
    
    func deleteNote(note: Note) {
        let headers: HTTPHeaders = [
           "Authorization": "Bearer \(Defaults.manager.getCurrentToken())",
           "Content-Type": "application/json"
       ]
       
        AF.request("\(Constants.nodeApi)/\(note._id)", method: .delete, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                print("Deleted note")
                return
            }
    }
    
    func updateNote(note: Note) {
       
       let headers: HTTPHeaders = [
          "Authorization": "Bearer \(Defaults.manager.getCurrentToken())",
          "Content-Type": "application/json"
       ]
        
            
        let parameters: [String : Any] =
            ["text" : note.text,
             "userId": note.userId,
             "_id": note._id,
             "completed": note.completed
            ]
       
        AF.request("\(Constants.nodeApi)/\(note._id)", method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
//            if response.error != nil {
//                Defaults.manager.appendOfflineNote(OfflineNote(text: text))
//                AlertManager.manager.showDisconnectedBannerNotification(title: "Error", message: "Could not add item, will try again when online", duration: 1)
//                return
//            }
        }
               
       
   }
//    func login(parameters: [String: Any], currentViewController: UIViewController) {
//        AF.request(Constants.authApi, method: .post, parameters: parameters, encoding: JSONEncoding.default)
//            .responseJSON { response in
//                print(response)
//                switch response.result {
//                case .success(_):
//                    guard let jsonData = try? JSONDecoder().decode(JSONResponse.self, from: response.data!) else { return
//                    }
//                    guard let token = jsonData.token else {
//                        AlertManager.manager.showDisconnectedBannerNotification(title: "Error", message: "Invalid credentials")
//                        return
//                    }
//
//                    Defaults.manager.storeToken(token: token)
////                    NavigationManager.manager.currentUserToken = token
//
//                    NavigationManager.manager.navigateToNavigationController(currentViewController: currentViewController)
//                case .failure(_):
//                    AlertManager.manager.showDisconnectedBannerNotification(title: "Error", message: "Network error")
//                }
//            }
//    }
    
}
