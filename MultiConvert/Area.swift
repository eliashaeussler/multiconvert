//
//  Area.swift
//  MultiConvert
//
//  Created by Elias Häußler on 18.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit

class Area: NSObject, QuantityProtocol {
    
    static let placeholder = "256.9"
    static var units: [UnitObj] = [
        UnitObj(key: "SQKM", symbol: "km\u{00B2}", name: "square kilometres", value: 1e-6),
        UnitObj(key: "SQM", symbol: "m\u{00B2}", name: "square metres", value: Quantities.BASE),
        UnitObj(key: "SQCM", symbol: "cm\u{00B2}", name: "square centimetres", value: 1e4),
        UnitObj(key: "SQMI", symbol: "mi\u{00B2}", name: "square miles", value: 1/2589988.110336),
        UnitObj(key: "SQYD", symbol: "yd\u{00B2}", name: "square yards", value: 1/0.83612736),
        UnitObj(key: "SQFT", symbol: "ft\u{00B2}", name: "square foot", value: 1/0.09290304),
        UnitObj(key: "SQIN", symbol: "in\u{00B2}", name: "square inches", value: 1/0.00064516),
        UnitObj(key: "AR", symbol: "a", name: "ares", value: 1e-2),
        UnitObj(key: "HEKTAR", symbol: "ha", name: "hectares", value: 1e-4),
        UnitObj(key: "ACRE", symbol: "ac", name: "acres", value: 1/4046.8564224)
    ]

}
