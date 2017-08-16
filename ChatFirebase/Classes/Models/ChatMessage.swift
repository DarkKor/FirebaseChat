//
//  ChatMessage.swift
//  ChatFirebase
//
//  Created by Dmitriy on 14.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import Foundation

class ChatMessage {
    var key: String!
    var userId: String!
    var userName: String!
    var text: String!
    var date: Date!
    var photoURL: String?
    var isOutgoing: Bool = false
    
    init(key: String, userId: String, date: Date, username: String, text: String, photoURL: String?, isOutgoing: Bool) {
        self.key = key
        self.userId = userId
        self.text = text
        self.date = date
        self.userName = username
        self.photoURL = photoURL
        self.isOutgoing = isOutgoing
    }
}
