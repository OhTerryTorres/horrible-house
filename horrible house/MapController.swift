//
//  MapController.swift
//  horrible house
//
//  Created by TerryTorres on 4/7/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation
import UIKit

class MapController: UIViewController {
    
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    
    var widthByRooms : CGFloat {
        return CGFloat(house.width)
    }
    var heightByRooms : CGFloat {
        return CGFloat(house.width)
    }
    
    var currentFloor = 1
    
    @IBOutlet var mapDisplayView: UIView!
    @IBOutlet var roomNameLabel: UILabel!
    
    override func viewDidLoad() {
        self.title = "Map"
        self.tabBarItem = UITabBarItem(title: "Map", image: nil, tag: 2)
        
        self.currentFloor = self.house.player.position.z
        
        self.mapDisplayView.frame.size.width = self.view.frame.width + (self.view.frame.width * 0.02)
        self.mapDisplayView.frame.size.height = self.view.frame.height
        
        let tabBarHeight = self.tabBarController!.tabBar.frame.height
        self.mapDisplayView.frame.size.height -= tabBarHeight + (tabBarHeight * 0.3)
        self.mapDisplayView.frame.size.height -= tabBarHeight
        
        self.setFloorButton()
        
        
    }
    
    func setFloorButton() {
        var string = ""
        switch (self.currentFloor) {
        case 0:
            string = "B"
        case 1:
            string = "1"
        case 2:
            string = "2"
        default:
            break
        }
        
        let changeFloorButton = UIBarButtonItem(title: string, style: UIBarButtonItemStyle.Plain, target: self, action: "changeFloor")
        navigationItem.rightBarButtonItem = changeFloorButton
    }
    
    override func viewWillAppear(animated: Bool) {
        self.currentFloor = self.house.player.position.z
        self.displayMap()
        
    }
    
    func displayMap() {
        for view in self.mapDisplayView.subviews {
            view.removeFromSuperview()
        }
        
        let width = self.mapDisplayView.frame.size.width
        let height = self.mapDisplayView.frame.size.height
        
        let roomWidth = width / CGFloat(widthByRooms)
        let roomHeight = height / CGFloat(heightByRooms)
        
        print("heightByRooms is \(heightByRooms)")
        print("widthByRooms is \(widthByRooms)")
        
        for var y = heightByRooms; y > -1; y-- {
            print("y is \(y)")
            for var x = widthByRooms; x > -1; x-- {
                print("x is \(x)")
                let roomView = UIView()
                roomView.frame = CGRectMake(
                    x * roomWidth,
                    y * roomHeight,
                    roomWidth ,
                    roomHeight
                )
                
                let room = house.roomForPosition((x:Int(x), y:Int(y), z:self.currentFloor))
                
                if room!.name != "No Room" {
                    print("\(room!.name)")
                    roomView.backgroundColor = UIColor.blackColor()
                    
                    if room?.timesEntered > 0 {
                        
                        /*
                        let roomButton = SuperButton(type: UIButtonType.Custom) as SuperButton
                        roomButton.qualifier = room!.name
                        
                        let buttonX = CGFloat(roomWidth * 0.125)
                        let buttonY = CGFloat(roomHeight * 0.125)
                        let buttonWidth = CGFloat(roomWidth * 0.75)
                        let buttonHeight = CGFloat(roomHeight * 0.75)
                        roomButton.frame = CGRectMake(
                            buttonX,
                            buttonY,
                            buttonWidth,
                            buttonHeight
                        )
                        
                        roomButton.titleLabel?.text = room!.name
                        
                        roomButton.setBackgroundImage(UIImage(named: "white"), forState: UIControlState.Normal)
                        roomButton.addTarget(self, action: Selector("displayRoomName:"), forControlEvents:.TouchDown)
                        roomButton.setTitle(roomButton.room!.name, forState: UIControlState.Normal)
                        
                        roomView.addSubview(roomButton)
                        */
                        
                        let roomDetailView = UIView()
                        let detailX = CGFloat(roomWidth * 0.125)
                        let detailY = CGFloat(roomHeight * 0.125)
                        let detailWidth = CGFloat(roomWidth * 0.75)
                        let detailHeight = CGFloat(roomHeight * 0.75)
                        roomDetailView.frame = CGRectMake(
                            detailX,
                            detailY,
                            detailWidth,
                            detailHeight
                        )
                        roomDetailView.backgroundColor = UIColor.lightGrayColor()
                        
                        roomView.addSubview(roomDetailView)
                        
                        roomView.transform = CGAffineTransformMakeScale(1, -1)
                    }
                    
                } else { roomView.backgroundColor = UIColor.darkGrayColor() }
                
                self.mapDisplayView.addSubview(roomView)
                
                // Flips map upside down, to match the house layout.
                self.mapDisplayView.transform = CGAffineTransformMakeScale(1, -1)
            }
        }
    }

    
    func displayRoomName(sender: SuperButton) {
        print("\(sender.qualifier)")
        
        let label = self.roomNameLabel
        
        label.text = sender.qualifier
        
        label.font = label.font.fontWithSize(70)
        
        print("label.center was \(label.center)")
        //label.center = sender.center
        print("label.center is \(label.center)")
        
        self.mapDisplayView.addSubview(label)
        
        
        /*
        UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: {
            label.hidden = false
            }, completion:{(Bool)  in
                UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: {
                    // Hold frame
                    }, completion:{(Bool)  in
                        UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: {
                            label.hidden = true
                            }, completion:nil)
                })
        })
        */
    }
    
    func changeFloor() {
        self.currentFloor++
        if self.currentFloor > 2 {
            self.currentFloor = 0
        }
        
        self.setFloorButton()
        
        self.displayMap()
    }
    
    
}