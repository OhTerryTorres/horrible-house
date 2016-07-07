//
//  GameTime.swift
//  horrible house
//
//  Created by TerryTorres on 4/26/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class GameTime: NSObject, NSCoding {
    
    var hours : Int = 12
    var minutes : Int = 0
    var seconds : Int = 0
    
    override init() {
        
    }
    
    init(var hours: Int, var minutes: Int, var seconds:Int) {
        while seconds >= 60 {
            seconds -= 60
            minutes++
        }
        self.seconds = seconds
        
        while minutes >= 60 {
            minutes -= 60
            hours++
        }
        self.minutes = minutes
        
        while hours > 12 {
            hours -= 12
        }
        self.hours = hours
    }
    
    func totalTimeInSeconds() -> Int {
        let h = (hours * 60) * 60
        let m = minutes * 60
        return seconds + m + h
    }
    
    func passTime(bySeconds seconds:Int) {
        let newTime = GameTime(
            hours: self.hours,
            minutes: self.minutes,
            seconds: self.seconds + seconds)
        self.hours = newTime.hours
        self.minutes = newTime.minutes
        self.seconds = newTime.seconds
    }
    
    
    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(self.hours, forKey: "hours")
        coder.encodeInteger(self.minutes, forKey: "minutes")
        coder.encodeInteger(self.seconds, forKey: "seconds")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        self.init(
            hours: decoder.decodeIntegerForKey("hours"),
            minutes: decoder.decodeIntegerForKey("minutes"),
            seconds: decoder.decodeIntegerForKey("seconds")
        )
    }
}
