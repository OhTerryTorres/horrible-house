//
//  NavigationController.swift
//  horrible house
//
//  Created by TerryTorres on 8/2/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func awakeFromNib() {
        
        self.navigationBar.setStyle()
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: Font.titleFont! ]
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        
        if var frame = self.navigationItem.titleView?.frame {            
            
            frame.origin.x = 10
            self.navigationItem.titleView!.frame = frame
        }
    }

}
