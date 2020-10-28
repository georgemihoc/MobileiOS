//
//  SocketService.swift
//  MobileiOS
//
//  Created by George on 27/10/2020.
//

import Foundation
import Starscream

struct Payload: Codable {
    let item: Item
}
struct MessageObject: Codable {
    let event: String
    let payload: Payload
}

class SocketService<T: Codable>: WebSocketDelegate {
    
    // MARK: - Private properties
    
    private let socket = WebSocket(url: URL(string: Constants.nodeApi)!)
    
    // MARK: - Public properties
    
    var didRecieveObject: (T) -> Void = { object in }
    
    // MARK: - Lifecycle
    
    init() {
        socket.delegate = self
        socket.connect()
    }
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Did connect")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Message received")
        
        if let data = text.data(using: .utf8, allowLossyConversion: false) {
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                didRecieveObject(object)
            } catch {
                print(error)
            }
        }
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        print("Got pong! Maybe some data: \(String(describing: data?.count))")
    }
}
