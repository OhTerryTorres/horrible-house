//
//  ContainerController.swift
//  horrible house
//
//  Created by TerryTorres on 5/9/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class ContainerController: UIViewController {
    
    var container = Item()

    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    
    @IBOutlet var tableViewContainer: UITableView!
    @IBOutlet var tableViewInventory: UITableView!
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        var items : [Item] = []
        
        if tableView == self.tableViewContainer {
            cell = tableView.dequeueReusableCellWithIdentifier("container", forIndexPath: indexPath)
            items = self.container.items
        }
        
        if tableView == self.tableViewInventory {
            cell = tableView.dequeueReusableCellWithIdentifier("inventory", forIndexPath: indexPath)
            items = self.house.player.items
        }
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel!.text = item.inventoryDescription
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var items : [Item] = []
        if tableView == self.tableViewContainer {
            items = self.container.items
            
        }
        
        if tableView == self.tableViewInventory {
            items = self.house.player.items
        }
        
        let item = items[indexPath.row]
        
        if tableView == self.tableViewContainer {
            self.house.player.addItemToItems(item)
            self.container.removeItemFromItems(withName: item.name)
            self.endCookingItemInOven(item)
        }
        if tableView == self.tableViewInventory {
            self.container.addItemToItems(item)
            self.house.player.removeItemFromItems(withName: item.name)
            self.startCookingItemInOven(item)
        }
        self.tableViewContainer.reloadData()
        self.tableViewInventory.reloadData()
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.refreshViewControllers()
        }
        
        
        // This is especially helpful for a shifting inventory
        self.house.skull.updateSkull()
        
    }
    
    // This starts the cooking timer on any items that were not in the oven before it was heated
    
    func startCookingItemInOven(item: Item) {
        if let oven = container as? Oven {
            if oven.isHeated {
                item.cookingTimeBegan = self.house.gameClock.currentTime
                // Delete this when done testing
                let timeItemsWillBeCooked = GameTime(hours: item.cookingTimeBegan!.hours, minutes: item.cookingTimeBegan!.minutes, seconds: item.cookingTimeBegan!.seconds + Oven.CookingTimes.secondsUntilCooked)
                print("\(item.name) be cooked at \(timeItemsWillBeCooked.hours):\(timeItemsWillBeCooked.minutes)")
            }
        }
        
    }
    
    func endCookingItemInOven(item: Item) {
        if let _ = container as? Oven {
            if let _ = item.cookingTimeBegan {
                print("\(item.name) is no longer being cooked")
                item.cookingTimeBegan = nil
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableViewContainer.reloadData()
        self.tableViewInventory.reloadData()
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var string = ""
        
        if tableView == self.tableViewContainer {
            string = self.container.name.uppercaseString
        }
        if tableView == self.tableViewInventory {
            string = "INVENTORY"
        }
        
        return string
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if tableView == self.tableViewContainer {
            rows = self.container.items.count
            
        }
        if tableView == self.tableViewInventory {
            rows = self.house.player.items.count
        }
        return rows
    }
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel!.font = UIFont.boldSystemFontOfSize(10)
    }
    
    
}
