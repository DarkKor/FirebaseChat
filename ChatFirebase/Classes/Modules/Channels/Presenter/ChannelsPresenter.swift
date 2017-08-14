//
//  ChannelsPresenter.swift
//  ChatFirebase
//
//  Created by Dmitriy on 13.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import UIKit

protocol ChannelsViewProtocol {
    func startLoading()
    func finishLoading()
    
    func newChannelDidAdd(_ channel: ChatChannelViewModel)
}

class ChannelsPresenter {
    var view: ChannelsViewProtocol!
    
    fileprivate var channels: [ChatChannel] = [ChatChannel]()
    
    fileprivate let chatManager = ChatManager.shared
    
    var senderId: String? {
        return chatManager.senderId
    }
    
    func startObservingNewChannels() {
        chatManager.startObservingNewChannels { [weak self] (channel) in
            guard let contains = self?.channels.contains(channel), !contains else {
                return
            }
            
            self?.channels.append(channel)
            
            if let viewModel = self?.channelViewModel(with: channel) {
                self?.view.newChannelDidAdd(viewModel)
            }
        }
    }
    
    func logout() {
        chatManager.logout()
        Router.shared.logout()
    }
    
    func openChannel(_ channel: ChatChannelViewModel) {
        if let channelToOpen = channels.first(where: { (eachChannel) -> Bool in
            return eachChannel.id == channel.channelId
        }) {
            Router.shared.openChannel(channelToOpen)
        }
    }
    
    func createNewChannel(_ channelName: String, with recipient: String) {
        chatManager.createNewChannel(channelName, with: recipient)
    }
}

private extension ChannelsPresenter {
    func channelViewModel(with channel: ChatChannel) -> ChatChannelViewModel {
        return ChatChannelViewModel(channel: channel)
    }
}
