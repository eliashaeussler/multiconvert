//
//  QuantityObj.swift
//  MultiConvert
//
//  Created by Elias Häußler on 25.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import Foundation

struct QuantityObj: Equatable, Comparable
{
    /** Quantity enum */
    var name: Quantity
    
    /** Units as unit objects */
    var units: [UnitObj]
    
    /** Check if tow quantities are equal */
    public static func ==(lhs: QuantityObj, rhs: QuantityObj) -> Bool
    {
        return lhs.name == rhs.name
    }
    
    /** Check if a quantities' key compared with another quantities' key is ordered ascending */
    public static func <(lhs: QuantityObj, rhs: QuantityObj) -> Bool
    {
        return lhs.name.rawValue.compare(rhs.name.rawValue) == .orderedAscending
    }
}
