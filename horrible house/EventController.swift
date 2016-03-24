//
//  EventController.swift
//  horrible house
//
//  Created by TerryTorres on 3/21/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class EventController: UITableViewController {

    enum Sections : Int {
        case update = 0
        case explanation = 1
        case items = 2
        case actions = 3
        case numberOfSections = 4
    }

    
    // self.house will allows access to self.house!.currentEvent and self.house.currntEvent.currentStage!
    // Then the house can be passed back to other viewcontrollers
    var house = House?()
    var update = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.house!.currentEvent.setCurrentStage()
        self.navigationItem.setHidesBackButton(true, animated:false);
        self.title = self.house!.currentEvent.currentStage!.name
        
        
        
    }
    
    // MARK: Tableview Functions
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return Sections.numberOfSections.rawValue
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rows = 0
        switch ( section ) {
        case Sections.update.rawValue:
            // Hide update section if self.update is empty
            if ( self.update != "" ) {
                rows = 1
            }
        case Sections.explanation.rawValue:
            rows = 1
        case Sections.items.rawValue:
            // Displays options to interact with carryable items, if any are present.
            rows = self.house!.currentEvent.currentStage!.items.count
        case Sections.actions.rawValue:
            rows = self.house!.currentEvent.currentStage!.numberOfActionsThatFollowTheRules()
        default:
            break;
        }
        return rows
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // Configure the cell...
        switch ( indexPath.section ) {
        case Sections.update.rawValue:
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.text = self.update
        case Sections.explanation.rawValue:
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.text = self.house!.currentEvent.currentStage!.explanation
            cell.userInteractionEnabled = false
        case Sections.items.rawValue:
            let item = self.house!.currentEvent.currentStage!.items[indexPath.row]
            cell.textLabel!.text = "Take \(item.name)"
            cell.userInteractionEnabled = true
        case Sections.actions.rawValue:
            let action = self.house!.currentEvent.currentStage!.actions[indexPath.row]
            cell.textLabel!.text = action.name
            cell.userInteractionEnabled = true
        default:
            break;
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch ( indexPath.section ) {
        case Sections.items.rawValue:
            let item = self.house!.currentEvent.currentStage!.items[indexPath.row]
            self.house!.player.addItemToItems(item)
            self.house!.currentEvent.currentStage!.removeItemFromItems(withName:item.name)
            self.update = "Got \(item)"
        case Sections.actions.rawValue:
            resolveAction(self.house!.currentEvent.currentStage!.actions[indexPath.row])
        default:
            break
        }
        self.tableView.reloadData()
    }
    
    
    func resolveAction(action: Action) {
        
        action.timesPerformed++
        if let result = action.result { self.update = result }
        if let roomChange = action.roomChange { self.house!.currentEvent.currentStage!.explanation = roomChange }
        for item in action.items {
            self.house!.currentEvent.currentStage!.items.append(item)
            action.onceOnly = true
        }
        
        for var i = 0; i < self.house!.currentEvent.currentStage!.actions.count; i++ {
            if self.house!.currentEvent.currentStage!.actions[i].name == action.name {
                self.house!.currentEvent.currentStage!.actions[i].timesPerformed += 1
                if let replaceAction = action.replaceAction {
                    self.house!.currentEvent.currentStage!.actions[i] = replaceAction
                }
                if action.onceOnly == true {
                    self.house!.currentEvent.currentStage!.actions.removeAtIndex(i)
                }
            }
        }
        
        if let triggerEventName = action.triggerEventName { triggerEvent(forEventName: triggerEventName)}
    }
    
    func triggerEvent(forEventName eventName: String) {
        for event in self.house!.events {
            if event.name == eventName {
                if event.isFollowingTheRules() {
                    self.house!.currentEvent = event
                }
            }
        }
        if eventName == "" {
            performSegueWithIdentifier("exit", sender: nil)
        }
    }
    

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "exit" {
            let ec = segue.destinationViewController as! ExplorationController
            ec.house = self.house!
        }
    
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = UITableViewAutomaticDimension
        if self.house!.currentEvent.currentStage!.actions[indexPath.row].isFollowingTheRules() == false {
            height = 0
        }
        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
