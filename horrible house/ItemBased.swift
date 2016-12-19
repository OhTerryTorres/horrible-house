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
            
            // This takes the items back out if it already exists in the Foyer box
            if let boxData = UserDefaults.standard.data(forKey: "boxData") {
                if let box = NSKeyedUnarchiver.unarchiveObject(with: boxData) as? Item {
                    if let _ = box.items.index(where: {$0.name == item!.name}) {
                        print("ITEMBASED - item is already in the box")
                        if let index = self.items.index(where: {$0.name == item!.name}) {
                            self.items.remove(at: index)
                        }
                    }
                }
            }
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
                self.items.remove(at: i)
                break // This keeps items with the same name from collapsing on each other.
            } else { i += 1 }
        }
        
    }
    
    // MARK: Resolve Action Functions
    
    func revealItemsWithNames(itemNames: [String]) {
        // REVEAL HIDDEN ITEMS
        for itemName in itemNames {
            if let index = self.items.index(where: {$0.name == itemName}) {
                self.items[index].hidden = false
            }
        }
    }
    
    func liberateItemsWithNames(itemNames: [String]) {
        // ALLOW STUCK/LOCKED ITEMS TO BE CARRIED
        for itemName in itemNames {
            if let index = self.items.index(where: {$0.name == itemName}) {
                self.items[index].enableCarrying()
            }
        }
    }
    
    func resolveChangesToItemsForAction(action: Action) {
        for item in self.items {
            item.resolveChangesToActionsForAction(action: action)
        }
    }
    
    func itemForActionName(actionName: String) -> Item? {
        var i : Item?
        for item in self.items {
            if (item.actions.index(where: {$0.name == actionName}) != nil) {
                i = item
            }
        }
        return i
    }
    
}
