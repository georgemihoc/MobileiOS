//
//  SocketService.swift
//  MobileiOS
//
//  Created by George on 27/10/2020.
//

import Foundation
import Starscream

struct Payload: Codable {
    let note: Note
}

struct MessageObject: Codable {
    let event: String
    let payload: Payload
}

class SocketService: WebSocketDelegate {
    
    
    static let socketService = SocketService()
    
    // MARK: - Private properties
    
    private let socket = WebSocket(url: URL(string: Constants.nodeApi)!)
    
    // MARK: - Public properties
    
    var didRecieveObject: (MessageObject) -> Void = { object in }
    
    // MARK: - Lifecycle
    
    init() {
        socket.delegate = self
        socket.connect()
    }
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Did connect")
        AlertManager.manager.showBannerNotification(title: "Connected", message: "You are connected to the server!")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Message received")
        
        if let data = text.data(using: .utf8, allowLossyConversion: false) {
            do {
                let object = try JSONDecoder().decode(MessageObject.self, from: data)
                didRecieveObject(object)
            } catch {
                print(error)
            }
        }
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
        AlertManager.manager.showDisconnectedBannerNotification(title: "Network error", message: "Could not establish server connection")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        print("Got pong! Maybe some data: \(String(describing: data?.count))")
    }
}
