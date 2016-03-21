//
//  Event.swift
//  horrible house
//
//  Created by TerryTorres on 3/19/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Event: NSObject {
    
    var name = ""
    var stages : [Stage]? = []
    var currentStage : Stage?
    var completed = false

    init(name: String) {
        self.name = name
    }
}
