//
//  Weight.swift
//  MultiConvert
//
//  Created by Elias Häußler on 18.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit

class Weight: NSObject, QuantityProtocol {
    
    static let placeholder = "87.3"
    static var units: [UnitObj] = [
        UnitObj(key: "T", symbol: "t", name: "tonnes", value: 1e-3),
        UnitObj(key: "KG", symbol: "kg", name: "kilograms", value: Quantities.BASE),
        UnitObj(key: "G", symbol: "g", name: "grams", value: 1e3),
        UnitObj(key: "GR", symbol: "gr", name: "grains", value: 1e-6*64.79891),
        UnitObj(key: "DRT", symbol: "dr", name: "drams", value: 1e-3*3.8879346),
        UnitObj(key: "OZ", symbol: "oz", name: "ounces", value: 1e3/28.349523125),
        UnitObj(key: "OZT", symbol: "oz t", name: "troy ounces", value: 1e3/31.1034768)
    ]

}
