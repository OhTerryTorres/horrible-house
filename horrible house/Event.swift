//
//  Event.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Event: NSObject {

    // MARK: Properties
    
    var name: String
    var explanation: String
    var actions = [Action]()
    
    
    init(name:String, explanation:String, actions:[Action]) {
        self.name = name
        self.explanation = explanation
        self.actions = actions
        
    }
    
}
