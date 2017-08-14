//
//  ChatMessage.swift
//  ChatFirebase
//
//  Created by Dmitriy on 14.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import Foundation

class ChatMessage {
    var userId: String!
    var userName: String!
    var text: String!
    var date: Date!
    
    init(userId: String, date: Date, username: String, text: String) {
        self.userId = userId
        self.text = text
        self.date = date
        self.userName = username
    }
}
