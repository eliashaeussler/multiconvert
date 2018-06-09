//
//  Converter.swift
//  MultiConvert
//
//  Created by Elias Häußler on 18.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit

class Converter: NSObject {
    
    /** Class for displaying a conversion */
    class Values
    {
        /** Selected quantity for conversion */
        public var quantity: QuantityObj? = nil
        
        /** Selected base unit for conversion */
        var inputUnit: UnitObj? = nil
        
        /** Selected target unit for conversion */
        var outputUnit: UnitObj? = nil
        
        /** Input value for conversion */
        var input: Double? = nil
        
        /** Result of conversion */
        var output: Double? = nil
        
        /** Date of conversion */
        var date: Date = Date()
        
        /** Initialize object of Converter.Values class */
        init(quantity: QuantityObj, inputUnit: UnitObj, outputUnit: UnitObj, input: Double)
        {
            self.quantity = quantity
            self.inputUnit = inputUnit
            self.outputUnit = outputUnit
            self.input = input
        }
    }
    
    /** Convert a given value from base to target units with a given quantity */
    static func convert(_ input: Double, quantity: QuantityObj, from inputUnit: UnitObj, to outputUnit: UnitObj) throws -> Values
    {
        if inputUnit != outputUnit
        {
            // Edit input
            let input = Double(String(input).replacingOccurrences(of: ",", with: ".")) ?? input
            
            // Output
            let output = Values(quantity: quantity, inputUnit: inputUnit, outputUnit: outputUnit, input: input)
            
            // Conversion settings
            let base = try Quantities.getBase(forQuantity: quantity.name)
            let units = try Quantities.getUnits(forQuantity: quantity.name, withBase: false)
            
            // Check if input and output units are convertable
            if inputUnit == base || units.contains(inputUnit)
            {
                if units.contains(outputUnit)
                {
                    // Convert if input unit is base unit
                    if inputUnit == base {
                        output.output = input * outputUnit.value
                    }
                        
                    // Convert from different base unit
                    else {
                        output.output = input * outputUnit.value / inputUnit.value
                    }
                    
                } else if outputUnit == base {
                    
                    // Convert to base unit
                    output.output = input / inputUnit.value
                    
                } else {
                    // No compatible output unit found
                    throw MCError.noCompatibleOutputUnit
                }
            } else {
                // No compatible input unit found
                throw MCError.noCompatibleInputUnit
            }
            
            return output
        }
        
        throw MCError.noDifferentUnits
    }

}
