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
            var item : Item?
            if dict["name"] as? String == "Oven" { print("it's an oven!!") ; item = Oven(withDictionary: dict) ; print("ITEMBASED – item.name is \(item!.name)") }
            else {
                item = Item(withDictionary: dict)
            }
            self.items += [item!]
        }
    }
    
    func getItemsForDictionary(dictArray:[Dictionary<String, AnyObject>]) -> [Item] {
        var items : [Item] = []
        for dict in dictArray {
            var item : Item?
            item = Item(withDictionary: dict)
            items += [item!]
        }
        return items
    }
    
    func addItemToItems(item:Item) {
        self.items += [item]
    }
    
    func removeItemFromItems(withName itemName: String) {
        var i = 0
        for item in self.items {
            if item.name == itemName {
                print("ITEMBASED – removing \(itemName) from items")
                self.items.removeAtIndex(i)
                break // This keeps items with the same name from collapsing on each other.
            } else { i += 1 }
        }
        
    }
    
}