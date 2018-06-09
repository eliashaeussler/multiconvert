//
//  Time.swift
//  MultiConvert
//
//  Created by Elias Häußler on 18.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit

class Time: NSObject, QuantityProtocol {
    
    static let placeholder = "3600"
    static var units: [UnitObj] = [
        UnitObj(key: "S", symbol: "s", name: "seconds", value: 60),
        UnitObj(key: "MIN", symbol: "min", name: "minutes", value: Quantities.BASE),
        UnitObj(key: "H", symbol: "h", name: "hours", value: 1/60),
        UnitObj(key: "D", symbol: "d", name: "days", value: 1/(60*24)),
        UnitObj(key: "A", symbol: "a", name: "years", value: 1/(60*24*365))
    ]

}
