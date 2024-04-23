//
//  WebSocketService.swift
//  LastestFinance
//
//  Created by WEI-TSUNG CHENG on 2024/4/23.
//

import Foundation
import Combine

class WebSocketService: NSObject {
    
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?

    let apiKey: String = ""
    lazy var baseURL = URL(string: "wss://ws.finnhub.io?token=\(apiKey)")!
    
    @Published var price: String = "0.0"
    
    func connect() {
        ensureDisconnected()
        webSocketTask = urlSession.webSocketTask(with: baseURL)
        webSocketTask?.delegate = self
        webSocketTask?.resume()
    }
    
    
    func sendMessage() {
        
        let string = "{\"type\":\"subscribe\",\"symbol\":\"IC MARKETS:1\"}"
        let message = URLSessionWebSocketTask.Message.string(string)
        
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    func receiveMessage() {
        
        webSocketTask?.receive(completionHandler: { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
                
            case .success(.string(let str)):
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(APIResponse.self, from: Data(str.utf8))
                    DispatchQueue.main.async {
                        
                        self.price = "\(String(describing: result.data[0].p))"
                    }
                } catch  {
                    print("error is \(error.localizedDescription)")
                }
                
                self.receiveMessage()
                
            default:
                break
            }
        })
    }
    
    private func ensureDisconnected() {
        if webSocketTask != nil {
            disConnect()
        }
    }
    
    func disConnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        cleanupWebSocketTask()
    }
    
    private func cleanupWebSocketTask() {
        webSocketTask?.cancel()
        webSocketTask = nil
    }
    
    deinit {
        ensureDisconnected()
    }
    
    
    func sendPing() {
        
        if webSocketTask == nil {
            print("webSocketTask is not exist")
        }
        
        webSocketTask?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Receive pong failed: \(error)")
            } else {
                print("Receive pong success")
            }
        })
    }
    
}

extension WebSocketService: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        print("URLSessionWebSocketTask is connected ⭕️")
        receiveMessage()
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        
        let reasonString: String
        if let reason = reason, let string = String(data: reason, encoding: .utf8) {
            reasonString = string
        } else {
            reasonString = "none"
        }
        print("URLSessionWebSocketTask is closed: code=\(closeCode), reason=\(reasonString) ❌")
    }
    
}
//                    {
//                       "data":[
//                          {
//                             "c":null,
//                             "p":1.06618,
//                             "s":"IC MARKETS:1",
//                             "t":1713756721306,
//                             "v":0
//                          },
//                          {
//                             "c":null,
//                             "p":1.06619,
//                             "s":"IC MARKETS:1",
//                             "t":1713756721732,
//                             "v":0
//                          }
//                       ],
//                       "type":"trade"
//                    }

