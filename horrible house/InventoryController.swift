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
        self.title = "Items"
        
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
        
        let item = self.inventoryArray[indexPath.row]
        
        cell.textLabel!.text = item.name
        cell.detailTextLabel!.text = item.explanation
        
        return cell
    }
    
}
