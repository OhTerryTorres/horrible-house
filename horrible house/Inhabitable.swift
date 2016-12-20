//
//  Inhabitable.swift
//  horrible house
//
//  Created by TerryTorres on 5/25/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation

protocol Inhabitable : class {
    var characters : [Character] { get set }
}

extension Inhabitable {
    
    func setCharactersForDictionary(dictArray:[Dictionary<String, AnyObject>]) {
        for dict in dictArray {
            let character = Character(withDictionary: dict)
            self.characters += [character]
        }
    }
}
