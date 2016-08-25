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
    
    // MARK: Resolve Action Functions
    
    func revealItemsWithNames(itemNames: [String]) {
        // REVEAL HIDDEN ITEMS
        for itemName in itemNames {
            if let index = self.items.indexOf({$0.name == itemName}) {
                self.items[index].hidden = false
            }
        }
    }
    
    func liberateItemsWithNames(itemNames: [String]) {
        // ALLOW STUCK/LOCKED ITEMS TO BE CARRIED
        for itemName in itemNames {
            if let index = self.items.indexOf({$0.name == itemName}) {
                self.items[index].enableCarrying()
            }
        }
    }
    
    func resolveChangesToItemsForAction(action: Action) {
        for item in self.items {
            item.resolveChangesToActionsForAction(action)
        }
    }
    
    func itemForActionName(actionName: String) -> Item {
        var i = Item()
        for item in self.items {
            if let index = item.actions.indexOf({$0.name == actionName}) {
                //i = item.actions[index]
            }
        }
        return i
    }
    
}