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
    }
    
    var toJSQMessage: JSQMessage? {
        return JSQMessage(senderId: message.userId,
                          senderDisplayName: "",
                          date: message.date,
                          text: message.text)
    }
}
