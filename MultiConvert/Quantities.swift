//
//  Quantities.swift
//  MultiConvert
//
//  Created by Elias Häußler on 20.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit

class Quantities: NSObject {
    
    //-- CONSTANTS
    
    /** Value for base unit */
    static let BASE = 1.0
    
    /** Classes for quantities */
    static let CLASSES: [Quantity: QuantityProtocol.Type] =
    [
        Quantity.Area: Area.self,
        Quantity.Currency: Currency.self,
        Quantity.Length: Length.self,
        Quantity.Speed: Speed.self,
        Quantity.Time: Time.self,
        Quantity.Weight: Weight.self
    ]
    
    
    
    /** Get unit object for given unit key */
    static func getUnit(_ unit: String, forQuantity quantity: Quantity) throws -> UnitObj?
    {
        let u = try getUnits(forQuantity: quantity, withBase: true)
        
        if let index = u.index(where: { $0.key == unit }) {
            return u[index]
        } else {
            throw MCError.noCompatibleUnit
        }
    }
    
    /** Get all units as unit objects */
    static func getUnits(forQuantity quantity: Quantity, withBase base: Bool) throws -> [UnitObj]
    {
        if let qClass = CLASSES[quantity] {
            // Units
            var units = qClass.units
            
            // Remove base
            if !base {
                units.remove(at: units.index(where: { $0.value == BASE })!)
            }
            
            return units
        } else {
            throw MCError.noCompatibleQuantity
        }
    }
    
    /** Get base unit object for given quantity */
    static func getBase(forQuantity quantity: Quantity) throws -> UnitObj
    {
        if let qClass = CLASSES[quantity] {
            if let index = qClass.units.index(where: { $0.value == BASE }) {
                return qClass.units[index]
            }
        }
        
        throw MCError.noCompatibleQuantity
    }
    
    /** Get placeholder for given quantity */
    static func getPlaceholder(forQuantity quantity: Quantity) throws -> String
    {
        if let qClass = CLASSES[quantity] {
            return try qClass.placeholder + " " + getBase(forQuantity: quantity).symbol
        } else {
            throw MCError.noCompatibleQuantity
        }
    }
    
    /** Get quantity object for given quantity enum */
    static func getQuantity(forObject object: Quantity) -> QuantityObj {
        return getQuantity(forString: object.rawValue)!
    }

    /** Get quantity object for given quantity enum raw value */
    static func getQuantity(forString raw: String) -> QuantityObj?
    {
        let q = getQuantities()
        return q[q.index(where: { $0.name.rawValue == raw })!]
    }
    
    /** Get all quantity objects */
    static func getQuantities() -> [QuantityObj]
    {
        // Get quantities
        var quantities: [QuantityObj] = []
        for (q, _) in CLASSES {
            try? quantities.append( QuantityObj(name: q, units: getUnits(forQuantity: q, withBase: true)) )
        }
        
        // Sort by alphabet
        quantities.sort(by: <)
        
        return quantities
    }
    
    /** Check if quantity exists */
    static func exists(_ quantity: Quantity) -> Bool {
        return (try? getBase(forQuantity: quantity)) != nil
    }

}
