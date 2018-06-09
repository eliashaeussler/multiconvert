//
//  ConversionObj.swift
//  MultiConvert
//
//  Created by Elias Häußler on 25.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import Foundation

struct ConversionObj
{
    /** Quantity */
    var quantity: QuantityObj
    
    /** Conversions */
    var conversion: [Converter.Values]
}
