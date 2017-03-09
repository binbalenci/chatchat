//
//  RoundedButton.swift
//  ChatChat
//
//  Created by Binh Bui on 09/03/2017.
//  Copyright © 2017 Binh Bui. All rights reserved.
//

import UIKit

// Add a constructor for manually defining a color based on their hex value
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

var textColor = UIColor(netHex:0x4A4A4A)

/* 
 Created a simple UIButton sublcass that uses the tintColor for its text
 and border colours and when highlighted changes its background to the tintColor
*/
class RoundedButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 1.0
        layer.borderColor = textColor.cgColor
        layer.cornerRadius = self.bounds.size.height / 2
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        setTitleColor(textColor, for: .normal)
        setTitleColor(UIColor.white, for: .highlighted)
        //setBackgroundImage(UIImage(co`lor: tintColor), for: .highlighted)
    }
}

