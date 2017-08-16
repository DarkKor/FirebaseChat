//
//  UIImage+Orientation.swift
//  ChatFirebase
//
//  Created by Dmitriy on 16.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import UIKit

extension UIImage {
    var orientationFixed: UIImage {
        if (self.imageOrientation == .up) {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage!
    }
}

