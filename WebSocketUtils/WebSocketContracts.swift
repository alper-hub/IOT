//
//  WebSocketDelegate.swift
//  Homey
//
//  Created by Alper Tufan on 6.12.2021.
//

import Foundation

protocol WebSocketDelegate: AnyObject {
    func connectionOpened()
    func connectionClosed()
    func messageReceived(message: String?)
    func dataReceived(data: Data?)
    func webSocketError(error: Error?, area: String)
}

protocol WebSocketProtocol: AnyObject {
    func openWSConnection(url: String)
    func closeWSConnection()
    func sendMessage(message: String)
}
