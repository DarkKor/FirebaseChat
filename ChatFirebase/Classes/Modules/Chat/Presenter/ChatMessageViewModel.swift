//
//  ChatMessageViewModel.swift
//  ChatFirebase
//
//  Created by Dmitriy on 14.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatMessageViewModel {
    var text: String!
    var formattedDate: String!
    
    fileprivate var message: ChatMessage!
    
    init(message: ChatMessage) {
        self.message = message
        
        self.text = message.text
        self.formattedDate = message.date.description
        
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
        ChatManager.shared.downloadImageFromStorage(message) { (image) in
            guard let image = image else {
                completion(nil)
                return
            }
            (self.jsqMessage?.media as! JSQPhotoMediaItem).image = image
            completion(image)
        }
    }
}

extension ChatMessageViewModel: Equatable {
    public static func ==(lhs: ChatMessageViewModel, rhs: ChatMessageViewModel) -> Bool {
        return lhs.messageKey == rhs.messageKey
    }
}
