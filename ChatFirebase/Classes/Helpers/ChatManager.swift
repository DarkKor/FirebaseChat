//
//  ChatManager.swift
//  ChatFirebase
//
//  Created by Dmitriy on 13.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class ChatManager {
    //  Channels
    fileprivate lazy var channelsRef: DatabaseReference = Database.database().reference().child("channels")
    fileprivate var myChannelsRefHandle: DatabaseHandle?
    fileprivate var meInChannelsRefHandle: DatabaseHandle?
    
    //  Chat
    fileprivate var channelRef: DatabaseReference?
    fileprivate var channelRefHandle: DatabaseHandle?
    fileprivate var messageRef: DatabaseReference?
    fileprivate var newMessageRefHandle: DatabaseHandle?
    fileprivate var updatedMessageRefHandle: DatabaseHandle?
    
    //  Storage for images
    fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://testchat-1e7c6.appspot.com")
    fileprivate let imageURLNotSetKey = "NOTSET"
    
    
    var senderId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var uid: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: "uid")
        }
        set {
            let defaults = UserDefaults.standard
            
            if newValue == nil {
                defaults.removeObject(forKey: "uid")
            }
            else {
                defaults.set(newValue, forKey: "uid")
            }
        }
    }
    
    fileprivate var newChannelsObservingBlock: ((ChatChannel)->())?
    fileprivate var newMessagesObservingBlock: ((ChatMessage)->())?
    fileprivate var updatedMessagesObservingBlock: ((ChatMessage)->())?
    
    deinit {
        removeObservers()
    }
    
    static let shared = ChatManager()
    private init() {
        Database.database().isPersistenceEnabled = true
    }
    
    var isLoggedIn: Bool {
        let user = Auth.auth().currentUser
        return user != nil
    }
}

//  MARK: - Auth
extension ChatManager {
    func login(_ uid: String, completion: @escaping (String?, Error?)->()) {
        Auth.auth().signInAnonymously { [weak self] (user, error) in
            if error == nil {
                self?.uid = uid
            }
            
            completion(user?.refreshToken, error)
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
        
        uid = nil
        
        removeObservers()
    }
}

//  MARK: - Channels
extension ChatManager {
    func startObservingNewChannels(completion: @escaping (ChatChannel) -> ()) {
        self.newChannelsObservingBlock = completion
        self.createNewChannelsObserver()
    }
    
    func createNewChannel(_ channelName: String, with userId: String) {
        guard let uid = uid else {
            return
        }
        
        let newChannelRef = channelsRef.childByAutoId()
        let channelItem = ["name": channelName,
                           "userId" : uid,
                           "anotherUserId" : userId]
        newChannelRef.setValue(channelItem)
    }
}

//  MARK: - Chat
extension ChatManager {
    func startObservingNewMessages(in channel: ChatChannel, completion: @escaping (ChatMessage) -> ()) {
        self.newMessagesObservingBlock = completion
        
        if self.channelRef == nil {
            self.channelRef = channelsRef.child(channel.id)
        }
        
        if self.messageRef == nil {
            self.messageRef = channelRef?.child("messages")
        }
        
        self.createNewMessagesObserver()
    }
    
    func startObservingUpdatedMessages(in channel: ChatChannel, completion: @escaping (ChatMessage) -> ()) {
        self.updatedMessagesObservingBlock = completion
        
        if self.channelRef == nil {
            self.channelRef = channelsRef.child(channel.id)
        }
        
        if self.messageRef == nil {
            self.messageRef = channelRef?.child("messages")
        }
        
        self.createUpdatedMessagesObserver()
    }
    
    func finishObservingNewMessages() {
        self.messageRef?.removeAllObservers()
        self.newMessagesObservingBlock = nil
        self.newMessageRefHandle = nil
        self.messageRef = nil
        self.channelRef = nil
    }
    
    func finishObservingUpdatedMessages() {
        self.messageRef?.removeAllObservers()
        self.updatedMessagesObservingBlock = nil
        self.updatedMessageRefHandle = nil
        self.messageRef = nil
        self.channelRef = nil
    }
    
    func createNewMessage(date: Date, username: String, text: String) {
        guard let uid = uid else {
            return
        }
        guard let itemRef = self.messageRef?.childByAutoId() else {
            return
        }
        itemRef.setValue(["userId": uid,
                          "date" : date.timeIntervalSince1970,
                          "username" : username,
                          "text": text])
    }
    
    func createNewPhotoMessage(date: Date, username: String) -> String? {
        guard let uid = uid else {
            return nil
        }
        guard let itemRef = self.messageRef?.childByAutoId() else {
            return nil
        }
        
        itemRef.setValue(["userId": uid,
                          "text" : "-",
                          "date" : date.timeIntervalSince1970,
                          "username" : username,
                          "photoURL": imageURLNotSetKey,
                          "senderId": senderId!])
        
        return itemRef.key
    }
    
    func addImage(_ path: String, toMessage withKey: String) {
        let itemRef = messageRef?.child(withKey)
        let url = self.storageRef.child((path)).description
        itemRef?.updateChildValues(["photoURL": url])
    }
}

//  MARK: - Content
extension ChatManager {
    func uploadImageToStorage(_ data: Data, completion: @escaping (StorageMetadata?) -> ()) {
        let path = "\(senderId!)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/img.jpg"
        self.storageRef.child(path).putData(data, metadata: nil) { (metadata, error) in
            completion(metadata)
        }
    }
    
    func downloadImageFromStorage(_ message: ChatMessage, completion: @escaping (UIImage?) -> ()) {
        guard let photoURL = message.photoURL, photoURL.hasPrefix("gs") else {
            completion(nil)
            return
        }
        
        let imageStorageRef = Storage.storage().reference(forURL: photoURL)
        imageStorageRef.getData(maxSize: INT64_MAX) { (data, error) in
            guard error == nil else {
                completion(nil)
                return
            }
            imageStorageRef.getMetadata(completion: { (metadata, metaDataError) in
                guard metaDataError == nil else {
                    completion(nil)
                    return
                }
                guard let data = data else {
                    completion(nil)
                    return
                }
                completion(UIImage(data: data))
            })
        }
    }
}

//  MARK: - Private Methods
private extension ChatManager {
    func removeObservers() {
        if let refHandle = myChannelsRefHandle {
            channelsRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = meInChannelsRefHandle {
            channelsRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = newMessageRefHandle {
            messageRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    func createNewChannelsObserver() {
        if let refHandle = myChannelsRefHandle {
            channelsRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = meInChannelsRefHandle {
            channelsRef.removeObserver(withHandle: refHandle)
        }
        
        let block = { [weak self] (snapshot: DataSnapshot) in
            let channelData = snapshot.value as! [String: Any]
            let id = snapshot.key
            if let userId = channelData["userId"] as? String,
                let anotherUserId = channelData["anotherUserId"] as? String,
                let name = channelData["name"] as? String, name.characters.count > 0 {
                self?.newChannelsObservingBlock?(ChatChannel(id: id,
                                                             userId: userId,
                                                             anotherUserId: anotherUserId,
                                                             name: name))
            }
        }
        
        //  Owner's channels
        let myChannelsQuery = self.channelsRef.queryOrdered(byChild: "userId").queryEqual(toValue: uid)
        myChannelsRefHandle = myChannelsQuery.observe(.childAdded, with: { (snapshot) in
            block(snapshot)
        })
        
        //  Recipient's channels
        let meChannelsQuery = self.channelsRef.queryOrdered(byChild: "anotherUserId").queryEqual(toValue: uid)
        meInChannelsRefHandle = meChannelsQuery.observe(.childAdded, with: { (snapshot) in
            block(snapshot)
        })
    }
    
    func createNewMessagesObserver() {
        self.newMessageRefHandle = self.messageRef?.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, Any>
            
            if let id = messageData["userId"] as? String,
                let timeInterval = messageData["date"] as? Double,
                let username = messageData["username"] as? String,
                let text = messageData["text"] as? String, text.characters.count > 0 {
                let message = ChatMessage(key: snapshot.key,
                                          userId: id,
                                          date: Date(timeIntervalSince1970: TimeInterval(timeInterval)),
                                          username: username,
                                          text: text,
                                          photoURL: messageData["photoURL"] as? String,
                                          isOutgoing: id == self.uid)
                self.newMessagesObservingBlock?(message)
            }
        })
    }
    
    func createUpdatedMessagesObserver() {
        self.updatedMessageRefHandle = self.messageRef?.observe(.childChanged, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, Any>
            
            if let id = messageData["userId"] as? String,
                let timeInterval = messageData["date"] as? Double,
                let username = messageData["username"] as? String,
                let text = messageData["text"] as? String, text.characters.count > 0 {
                let message = ChatMessage(key: snapshot.key,
                                          userId: id,
                                          date: Date(timeIntervalSince1970: TimeInterval(timeInterval)),
                                          username: username,
                                          text: text,
                                          photoURL: messageData["photoURL"] as? String,
                                          isOutgoing: id == self.uid)
                self.updatedMessagesObservingBlock?(message)
            }
        })
    }
    
}
