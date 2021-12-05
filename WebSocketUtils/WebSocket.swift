//
//  WebSocket.swift
//  Homey
//
//  Created by Alper Tufan on 6.12.2021.
//

import Foundation

final class WebSocket: NSObject {

    private var webSocket: URLSessionWebSocketTask?
    weak var webSocketDelegate: WebSocketDelegate?
    
    private func openConnection() {
        webSocket?.resume()
    }

    private func closeConnection() {
        webSocket?.cancel(with:  .goingAway, reason: "User Canceled".data(using: .utf8 ))
    }

    private func ping() {
        webSocket?.sendPing  { [weak self] pingError in
            self?.webSocketDelegate?.webSocketError(error: pingError, area: "Ping")
        }
    }

    private func send(message: String) {
        webSocket?.send(.string(message), completionHandler: { [weak self] messageError in
            self?.webSocketDelegate?.webSocketError(error: messageError, area: "Sending Message")
        })
    }

    private func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.webSocketDelegate?.dataReceived(data: data)
                case .string(let message):
                    self?.webSocketDelegate?.messageReceived(message: message)
                @unknown default:
                    break
                }
            case .failure(let error):
                self?.webSocketDelegate?.webSocketError(error: error, area: "Receive")
            }
            self?.receive()
        })
    }
}

extension WebSocket: URLSessionWebSocketDelegate {

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        ping()
        receive()
        webSocketDelegate?.connectionOpened()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        webSocketDelegate?.connectionClosed()
    }
}

extension WebSocket: WebSocketProtocol {

    func openWSConnection(url: String) {
        let url = URL(string: url)!
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        
        webSocket =  session.webSocketTask(with: url)
        openConnection()
    }
    
    func closeWSConnection() {
        closeConnection()
    }
    
    func sendMessage(message: String) {
        send(message: message)
    }
}
