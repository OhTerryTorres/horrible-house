//
//  Room.swift
//  horrible house
//
//  Created by TerryTorres on 2/10/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Room: NSObject {
    
    // MARK: Properties
    
    var name: String
    var explanation: String
    var actions = [String]()
    var position = (x: 0, y: 0)
    var timesEntered: Int?
    
    //
    // Consider putting an init method in if we need this class to be more robust
    //
    init(name:String, explanation:String, actions:[String]) {
        self.name = name
        self.explanation = explanation
        self.actions = [String]()
    }
    
}
