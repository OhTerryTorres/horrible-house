
//
//  ContainerController.swift
//  horrible house
//
//  Created by TerryTorres on 5/9/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class ContainerController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var container = Item()

    var house : House = (UIApplication.shared.delegate as! AppDelegate).house
    
    @IBOutlet var tableViewContainer: UITableView!
    @IBOutlet var tableViewInventory: UITableView!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("creating cell")
        
        var items : [Item] = []
        var identifier = ""
        
        if tableView == self.tableViewContainer {
            identifier = "container"
            items = self.container.items
        }
        
        if tableView == self.tableViewInventory {
            identifier = "inventory"
            items = self.house.player.items
        }
        
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.setStyle()
        cell.textLabel!.numberOfLines = 0
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.inventoryDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        var items : [Item] = []
        if tableView == self.tableViewContainer {
            items = self.container.items
            
        }
        
        if tableView == self.tableViewInventory {
            items = self.house.player.items
        }
        
        let item = items[indexPath.row]
        
        if tableView == self.tableViewContainer {
            self.house.player.addItemToItems(item: item)
            self.container.removeItemFromItems(withName: item.name)
            self.endCookingItemInOven(item: item)
        }
        if tableView == self.tableViewInventory {
            self.container.addItemToItems(item: item)
            self.house.player.removeItemFromItems(withName: item.name)
            self.startCookingItemInOven(item: item)
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableViewContainer.reloadData()
        self.tableViewInventory.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // This allows the note to set a new safe box.
        if let _ = self.container.items.index(where: {$0.name == "Handwritten Note"}) {
            self.house.safeBox = self.container
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var string = ""
        
        if tableView == self.tableViewContainer {
            string = self.container.name.uppercased()
        }
        if tableView == self.tableViewInventory {
            string = "INVENTORY"
        }
        print("title for header in section \(section) is \(string)")
        return string
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if tableView == self.tableViewContainer {
            rows = self.container.items.count
            
        }
        if tableView == self.tableViewInventory {
            rows = self.house.player.items.count
        }
        print("rows in section \(section) is \(rows)")
        return rows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("number of sections in tableView is 1")
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        var frame = header.frame
        frame.size.height = 10
        header.frame = frame
        
        header.textLabel!.font = Font.headerFont
        header.textLabel!.frame = header.frame
        
        header.backgroundView?.backgroundColor = Color.foregroundColor
        header.textLabel!.textColor = Color.backgroundColor
    }
    
    override func viewDidLoad() {
        self.view.setStyle()
        self.tableViewContainer.setStyle()
        self.tableViewInventory.setStyle()
        
        self.tableViewContainer.dataSource = self
        self.tableViewContainer.delegate = self
        self.tableViewContainer.register(UITableViewCell.self, forCellReuseIdentifier: "container")
        
        self.tableViewInventory.dataSource = self
        self.tableViewInventory.delegate = self
        self.tableViewInventory.register(UITableViewCell.self, forCellReuseIdentifier: "inventory")

    }
    
    
}
