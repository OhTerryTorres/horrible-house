//
//  InventoryController.swift
//  horrible house
//
//  Created by TerryTorres on 4/7/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class InventoryController: UITableViewController {
    
    var inventoryArray : [Item] = []
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setStyle()
        
        self.title = "Items"
        self.tabBarItem = UITabBarItem(title: "Items", image: nil, tag: 1)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.inventoryArray = house.player.items
        self.tableView.reloadData()
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.inventoryArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.setStyle()
        
        cell.userInteractionEnabled = false
        
        let item = self.inventoryArray[indexPath.row]
        
        cell.textLabel!.text = item.name
        cell.detailTextLabel!.text = item.inventoryDescription
        
        if let eventName = item.inventoryEvent {
            if let index = self.house.events.indexOf({$0.name == eventName}) {
                if self.house.events[index].isFollowingTheRules() {
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    cell.userInteractionEnabled = true
                }
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.inventoryArray[indexPath.row]
        
        if let eventName = item.inventoryEvent {
            if let index = self.house.events.indexOf({$0.name == eventName}) {
                self.house.currentEvent = self.house.events[index]
                performSegueWithIdentifier("event", sender: nil)
            }            
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).house = self.house
        
        if segue.identifier == "event" {
            let ec = segue.destinationViewController as! EventController
            ec.house = self.house
            ec.isInventoryEvent = true
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        
    }
    
}
