//
//  ChatMessageViewModel.swift
//  ChatFirebase
//
//  Created by Dmitriy on 14.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import UIKit
import Kingfisher
import JSQMessagesViewController

class ChatMessageViewModel {
    fileprivate var message: ChatMessage!
    
    init(message: ChatMessage) {
        self.message = message
        
        if hasImage {
            self.jsqMessage = JSQMessage(senderId: message.userId,
                                         senderDisplayName: message.userName,
                                         date: message.date,
                                         media: JSQPhotoMediaItem(maskAsOutgoing: message.isOutgoing))
        }
        else {
            self.jsqMessage = JSQMessage(senderId: message.userId,
                                         senderDisplayName: message.userName,
                                         date: message.date,
                                         text: message.text)
        }
    }
    
    var jsqMessage: JSQMessage?
    
    var isOutgoing: Bool {
        return message.isOutgoing
    }
    
    var text: String! {
        return message.text
    }
    
    var userDisplayName: String! {
        return message.userName
    }
    
    var formattedDate: String! {
        return message.date.description
    }
    
    var hasImage: Bool {
        return message.photoURL != nil
    }
    
    var isImageDownloaded: Bool {
        guard hasImage else {
            return false
        }
        guard let jsqMessage = jsqMessage else {
            return false
        }
        guard let mediaItem = jsqMessage.media as? JSQPhotoMediaItem else {
            return false
        }
        return mediaItem.image != nil
    }
    
    var messageKey: String {
        return message.key
    }
    
    func loadImage(_ completion: @escaping (UIImage?) -> ()) {
        if let image = imageFromCache {
            (self.jsqMessage?.media as! JSQPhotoMediaItem).image = image
            completion(image)
        }
        else {
            ChatManager.shared.downloadImageFromStorage(message) { (image) in
                guard let image = image else {
                    completion(nil)
                    return
                }
                (self.jsqMessage?.media as! JSQPhotoMediaItem).image = image
                self.storeImage(image)
                completion(image)
            }
        }
    }
    
    private var imageFromCache: UIImage? {
        guard let key = message.photoURL else {
            return nil
        }
        
        var image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: key)
        if image == nil {
            image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: key)
        }
        
        return image
    }
    
    private func storeImage(_ image: UIImage) {
        guard let key = message.photoURL else {
            return
        }
        
        KingfisherManager.shared.cache.store(image, forKey: key)
    }
}

extension ChatMessageViewModel: Equatable {
    public static func ==(lhs: ChatMessageViewModel, rhs: ChatMessageViewModel) -> Bool {
        return lhs.messageKey == rhs.messageKey
    }
}
