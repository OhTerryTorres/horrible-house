//
//  ArrayExtension.swift
//  horrible house
//
//  Created by TerryTorres on 2/13/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

extension Array {
    func shiftRight(amount: Int = 1) -> [Element] {
        var amount = amount
        assert(-count...count ~= amount, "Shift amount out of bounds")
        if amount < 0 { amount += count }  // this needs to be >= 0
        return Array(self[amount ..< count] + self[0 ..< amount])
    }
    
    mutating func shiftRightInPlace(amount: Int = 1) {
        self = shiftRight(amount: amount)
    }
    
    
}

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        // *********** will this work?
        for i in startIndex..<endIndex {
            let j = Int(arc4random_uniform(UInt32(endIndex))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
        
        /*
         for i in 0..<count - 1 {
         let j = Int(arc4random_uniform(UInt32(count - i))) + i
         guard i != j else { continue }
         swap(&self[i], &self[j])
         }
        */
    }
}
