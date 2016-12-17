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
    
    override func viewWillAppear(_ animated: Bool) {
        self.inventoryArray = house.player.items
        self.tableView.reloadData()
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.inventoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let item = self.inventoryArray[indexPath.row]
        
        if let eventName = item.inventoryEvent {
            if let index = self.house.events.index(where: {$0.name == eventName}) {
                self.house.currentEvent = self.house.events[index]
                performSegue(withIdentifier: "event", sender: nil)
            }            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
