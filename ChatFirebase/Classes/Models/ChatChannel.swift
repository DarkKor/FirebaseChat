//
//  ChatChannel.swift
//  ChatFirebase
//
//  Created by Dmitriy on 13.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import Foundation
import ObjectMapper

class ChatChannel {
    var id: String!
    var name: String!
    var userId: String!
    var anotherUserId: String!
    
    init(id: String, userId: String, anotherUserId: String, name: String) {
        self.id = id
        self.userId = userId
        self.anotherUserId = anotherUserId
        self.name = name
    }
    
    var description: String {
        return "\(id), from \(userId), to \(anotherUserId), \(name)"
    }
}

extension ChatChannel: Equatable {
    public static func ==(lhs: ChatChannel, rhs: ChatChannel) -> Bool {
        return lhs.id == rhs.id
    }
}
