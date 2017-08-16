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
    func messageDidUpdate(_ message: ChatMessageViewModel)
    
    func imageWasUploaded()
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
    
    func startObservingMessages() {
        chatManager.startObservingNewMessages(in: channel) { [weak self] (message) in
            let messageViewModel = ChatMessageViewModel(message: message)
            self?.view.messageDidAdd(messageViewModel)
        }
        
        chatManager.startObservingUpdatedMessages(in: channel) { [weak self] (message) in
            let messageViewModel = ChatMessageViewModel(message: message)
            self?.view.messageDidUpdate(messageViewModel)
        }
    }
    
    func finishObservingMessages() {
        chatManager.finishObservingNewMessages()
        chatManager.finishObservingUpdatedMessages()
    }

    func addMessage(_ text: String, date: Date) {
        let userName = UserDefaults.standard.object(forKey: "username") as! String
        chatManager.createNewMessage(date: date, username: userName, text: text)
    }
    
    func addFakePhotoMessage(date: Date) -> String? {
        let userName = UserDefaults.standard.object(forKey: "username") as! String
        return chatManager.createNewPhotoMessage(date: date, username: userName)
    }
    
    func uploadImage(_ data: Data, completion: @escaping (String?) -> ()) {
        chatManager.uploadImageToStorage(data) { (metadata) in
            completion(metadata?.path)
        }
    }
    
    func updatePhotoMessage(_ messageKey: String, with photoPath: String) {
        chatManager.addImage(photoPath, toMessage: messageKey)
    }
}
