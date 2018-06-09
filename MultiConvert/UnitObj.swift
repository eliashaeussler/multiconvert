//
//  UnitObj.swift
//  MultiConvert
//
//  Created by Elias Häußler on 25.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import Foundation

struct UnitObj: Equatable, Comparable
{
    /** Key of unit */
    var key: String
    
    /** Symbol of unit */
    var symbol: String
    
    /** Name of unit */
    var name: String
    
    /** Conversion value for unit */
    var value: Double
    
    /** Check if two units are equal */
    public static func ==(lhs: UnitObj, rhs: UnitObj) -> Bool
    {
        return
            lhs.key == rhs.key &&
            lhs.symbol == rhs.symbol &&
            lhs.name == rhs.name
    }
    
    /** Check if a unit's key compared with another unit's key is ordered ascending */
    public static func <(lhs: UnitObj, rhs: UnitObj) -> Bool
    {
        return lhs.key.compare(rhs.key) == .orderedAscending
    }
}
