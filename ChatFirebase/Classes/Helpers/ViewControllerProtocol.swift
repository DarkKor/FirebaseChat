//
//  ViewControllerProtocol.swift
//  Gifteka
//
//  Created by Виктор Заикин on 17.10.16.
//  Copyright © 2016 Виктор Заикин. All rights reserved.
//

import UIKit

protocol ViewControllerProtocol {
    static func storyBoardName() -> String
}

// MARK:- Create
extension ViewControllerProtocol where Self: UIViewController {
    static func create() -> Self {
                
        let storyboard = self.storyboard()
        
        let className = NSStringFromClass(Self.self)
        let finalClassName = className.components(separatedBy: ".").last!
        let viewControllerId = finalClassName + "ID"
        
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerId)
        
        return viewController as! Self
    }
    
    static func storyboard() -> UIStoryboard {
        return UIStoryboard(name: storyBoardName(), bundle: nil)
    }
}
