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
        }
        if tableView == self.tableViewInventory {
            self.container.addItemToItems(item)
            self.house.player.removeItemFromItems(withName: item.name)
        }
        self.tableViewContainer.reloadData()
        self.tableViewInventory.reloadData()
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.refreshViewControllers()
        }
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var string = ""
        
        if tableView == self.tableViewContainer {
            string = self.container.name
        }
        if tableView == self.tableViewInventory {
            string = "Inventory"
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
    
    
}
