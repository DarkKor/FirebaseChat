//
//  ChatPresenter.swift
//  ChatFirebase
//
//  Created by Dmitriy on 14.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import Foundation
import Firebase

protocol ChatViewProtocol {
    func messageDidAdd(_ message: ChatMessageViewModel)
}

class ChatPresenter {
    var channel: ChatChannel!
    var view: ChatViewProtocol!
    
    fileprivate let chatManager = ChatManager.shared
    
    var uid: String? {
        return chatManager.uid
    }
    
    var channelName: String {
        return channel.name
    }
    
    func startObservingNewMessages() {
        chatManager.startObservingNewMessages(in: channel) { [weak self] (message) in
            let messageViewModel = ChatMessageViewModel(message: message)
            self?.view.messageDidAdd(messageViewModel)
        }
    }
    
    func finishObservingNewMessages() {
        chatManager.finishObservingNewMessages()
    }

    func addMessage(_ text: String, date: Date) {
        let userName = UserDefaults.standard.object(forKey: "username") as! String
        chatManager.createNewMessage(date: date, username: userName, text: text)
    }
    
    func addMessage(_ image: Data) {
        
    }
}
