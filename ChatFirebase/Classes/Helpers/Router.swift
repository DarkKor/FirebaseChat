//
//  Router.swift
//  ChatFirebase
//
//  Created by Dmitriy on 13.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import UIKit

class Router {
    class var shared: Router {
        return Router()
    }
    private init() {}
    
    func rootViewController() -> UINavigationController {
        let controller = LoginViewController.create()
        
        let presenter = LoginPresenter()
        presenter.view = controller
        
        controller.presenter = presenter
        let navController = UINavigationController(rootViewController: controller)
        
        if ChatManager.shared.isLoggedIn {
            let controller = ChannelsViewController.create()
            
            let presenter = ChannelsPresenter()
            presenter.view = controller
            
            controller.presenter = presenter
            
            navController.pushViewController(controller, animated: true)
        }
        
        return navController
    }
    
    func openChannels() {
        let controller = ChannelsViewController.create()
        
        let presenter = ChannelsPresenter()
        presenter.view = controller
        
        controller.presenter = presenter
        
        rootNavigationController?.pushViewController(controller, animated: true)
    }
    
    func openChannel(_ channel: ChatChannel) {
        let controller = ChatViewController.create()
        
        let presenter = ChatPresenter()
        presenter.view = controller
        presenter.channel = channel
        
        controller.presenter = presenter
        
        rootNavigationController?.pushViewController(controller, animated: true)
    }
    
    func logout() {
        _ = rootNavigationController?.popToRootViewController(animated: true)
    }
}

extension Router {
    var rootNavigationController: UINavigationController? {
        let appDelegate = UIApplication.shared.delegate
        let navController = appDelegate?.window??.rootViewController
        return navController as? UINavigationController
    }
}
