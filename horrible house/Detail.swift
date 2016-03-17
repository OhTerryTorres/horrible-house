//
//  Detail.swift
//  horrible house
//
//  Created by TerryTorres on 3/16/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Detail: NSObject {

    var explanation : String
    
    var rules : [Rule]? = []
    
    init(explanation:String) {
        
        self.explanation = explanation
        
    }
}
