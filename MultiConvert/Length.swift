//
//  Length.swift
//  MultiConvert
//
//  Created by Elias Häußler on 18.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit

class Length: NSObject, QuantityProtocol {
    
    static let placeholder = "78.2"
    static var units: [UnitObj] = [
        UnitObj(key: "KM", symbol: "km", name: "kilometres", value: 1e-3),
        UnitObj(key: "M", symbol: "m", name: "metres", value: Quantities.BASE),
        UnitObj(key: "DM", symbol: "dm", name: "decimetres", value: 10),
        UnitObj(key: "CM", symbol: "cm", name: "centimetres", value: 1e2),
        UnitObj(key: "MM", symbol: "mm", name: "millimetres", value: 1e3),
        UnitObj(key: "IN", symbol: "in", name: "inches", value: 1/0.0254),
        UnitObj(key: "FT", symbol: "ft", name: "foot", value: 1/0.3048),
        UnitObj(key: "YD", symbol: "yd", name: "yards", value: 1/0.9144),
        UnitObj(key: "MI", symbol: "mi", name: "miles", value: 1/1609.344)
    ]

}
