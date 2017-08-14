//
//  ChatChannelViewModel.swift
//  ChatFirebase
//
//  Created by Dmitriy on 13.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import UIKit

class ChatChannelViewModel {
    fileprivate var channel: ChatChannel!
    
    var title: String {
        return channel.name
    }
    
    var channelId: String {
        return channel.id
    }
    
    init(channel: ChatChannel) {
        self.channel = channel
    }
}
