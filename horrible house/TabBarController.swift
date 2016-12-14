//
//  TabBarController.swift
//  horrible house
//
//  Created by TerryTorres on 4/7/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    
    var defaultViewControllers : [UIViewController] = []
    
    override func awakeFromNib() {
        
        self.defaultViewControllers = self.viewControllers!
        self.tabBar.setStyle()
        self.tabBar.backgroundImage = UIImage()
    }
    
    // Change this so that the appropriate tabs aren't taken away from a saved game
    // ie, if the player already has the map, or other items
    func removeExcessViewControllersFromTabBarController() {
        var viewControllers = self.viewControllers
        var i = 0
        for viewController in viewControllers! {
            if viewController.title?.range(of: "Map") != nil && (UIApplication.shared.delegate as! AppDelegate).house.player.items.index(where: {$0.name == "Map"}) == nil {
                viewControllers?.remove(at: i)
                print("no Map tab")
            }
            else if viewController.title?.range(of: "Time") != nil && (UIApplication.shared.delegate as! AppDelegate).house.player.items.index(where: {$0.name == "Pocketwatch"}) == nil {
                viewControllers?.remove(at: i)
                print("no Time tab")
            }
            else if viewController.title?.range(of: "Skull") != nil && (UIApplication.shared.delegate as! AppDelegate).house.player.items.index(where: {$0.name == "Skull"}) == nil {
                viewControllers?.remove(at: i)
                print("no Skull tab")
            }
            else if viewController.title?.range(of: "Item") != nil && (UIApplication.shared.delegate as! AppDelegate).house.player.items.count == 0 {
                viewControllers?.remove(at: i)
                print("no Item tab")
            }
            else {i += 1}
        }
        print("viewControllers.count is \(viewControllers!.count)")
        self.viewControllers = viewControllers
        
        if (self.viewControllers?.count)! < 2 {
            self.tabBar.isHidden = true
        } else { self.tabBar.isHidden = false }
    }
    
    func refreshViewControllers() {
        print("refreshViewControllers")
        self.viewControllers = self.defaultViewControllers
        removeExcessViewControllersFromTabBarController()
    }
    
    func addViewControllerToTabBarController(tabIndex : TabIndex) {
        
        self.tabBar.isHidden = false
        
        var viewControllers : [UIViewController] = []
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Make a new array of viewcontrollers from scratch.
        // Go through and check if the right items are in the player inventory.
        // If they are, add the appropriate view controller to the array.
        // If the new array does not match the old one, replace the old one.
        
        switch tabIndex {
        case .inventory: // INVENTORY
            let ic = storyboard.instantiateViewController(withIdentifier: "NavigationInventoryController") as! UINavigationController
            if (self.viewControllers?.count)! > 2 {
                viewControllers.insert(ic, at: 1)
            } else { viewControllers.append(ic) }
        case .map: // MAP
            let mc = storyboard.instantiateViewController(withIdentifier: "NavigationMapController") as! UINavigationController
            if (self.viewControllers?.count)! > 3 {
                viewControllers.insert(mc, at: 2)
            } else { viewControllers.append(mc) }
        case .clock: // CLOCK
            let cc = storyboard.instantiateViewController(withIdentifier: "NavigationClockController") as! UINavigationController
            if (self.viewControllers?.count)! > 4 {
                viewControllers.insert(cc, at: 3)
            } else { viewControllers.append(cc) }
        case .skull: // SKULL
            let sc = storyboard.instantiateViewController(withIdentifier: "NavigationSkullController") as! UINavigationController
            if (self.viewControllers?.count)! > 5 {
                viewControllers.insert(sc, at: 4)
            }
            viewControllers.append(sc)
        default:
            break
        }
        
        self.viewControllers = viewControllers
    }
    
}

