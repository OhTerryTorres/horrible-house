//
//  ItemBased.swift
//  horrible house
//
//  Created by TerryTorres on 3/22/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation

protocol ItemBased : class {
    var items : [Item] { get set }
}

extension ItemBased {
    func setItemsForDictionary(dictArray:[Dictionary<String, AnyObject>]) {
        for dict in dictArray {
            let item = Item(withDictionary: dict)
            self.items += [item]
        }
    }
    
    func addItemToItems(item:Item) {
        self.items += [item]
    }
    
    func removeItemFromItems(withName itemName: String) {
        var i = 0
        for item in self.items {
            if item.name == itemName {
                self.items.removeAtIndex(i)
            } else { i++ }
        }
        
    }
    
}