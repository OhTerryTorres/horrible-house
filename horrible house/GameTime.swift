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
    
    init(hours: Int, minutes: Int, seconds:Int) {
        var seconds = seconds
        var minutes = minutes
        var hours = hours
        while seconds >= 60 {
            seconds -= 60
            minutes += 1
        }
        self.seconds = seconds
        
        while minutes >= 60 {
            minutes -= 60
            hours += 1
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
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.hours, forKey: "hours")
        coder.encode(self.minutes, forKey: "minutes")
        coder.encode(self.seconds, forKey: "seconds")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        self.init(
            hours: decoder.decodeInteger(forKey: "hours"),
            minutes: decoder.decodeInteger(forKey: "minutes"),
            seconds: decoder.decodeInteger(forKey: "seconds")
        )
    }
}
