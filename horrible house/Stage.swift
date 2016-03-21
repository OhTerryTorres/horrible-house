//
//  Stage.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Stage: NSObject {

    // MARK: Properties
    
    var name = ""
    var explanation = ""
    var actions : [Action]? = []
    var rules: [Rule]? = []
    
    var completed = false
    
    
    override init() {
        
        
    }
    
}
