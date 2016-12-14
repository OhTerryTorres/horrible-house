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
    var house : House = (UIApplication.shared.delegate as! AppDelegate).house
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setStyle()
        
        self.title = "Items"
        self.tabBarItem = UITabBarItem(title: "Items", image: nil, tag: 1)
        
    }
    
    func viewWillAppear(animated: Bool) {
        self.inventoryArray = house.player.items
        self.tableView.reloadData()
    }
    

    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.inventoryArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.setStyle()
        
        cell.isUserInteractionEnabled = false
        
        let item = self.inventoryArray[indexPath.row]
        
        cell.textLabel!.text = item.name
        cell.detailTextLabel!.text = item.inventoryDescription
        
        if let eventName = item.inventoryEvent {
            if let index = self.house.events.index(where: {$0.name == eventName}) {
                if self.house.events[index].isFollowingTheRules() {
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    cell.isUserInteractionEnabled = true
                }
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.inventoryArray[indexPath.row]
        
        if let eventName = item.inventoryEvent {
            if let index = self.house.events.index(where: {$0.name == eventName}) {
                self.house.currentEvent = self.house.events[index]
                performSegue(withIdentifier: "event", sender: nil)
            }            
        }
    }
    
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        (UIApplication.shared.delegate as! AppDelegate).house = self.house
        
        if segue.identifier == "event" {
            let ec = segue.destination as! EventController
            ec.house = self.house
            ec.isInventoryEvent = true
            ec.house.currentEvent.currentStage = ec.house.currentEvent.getStageThatFollowsRulesFromStagesArray(stages: ec.house.currentEvent.stages)
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        
    }
    
}
