//
//  Speed.swift
//  MultiConvert
//
//  Created by Elias Häußler on 18.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit

class Speed: NSObject, QuantityProtocol {
    
    static let placeholder = "50.0"
    static var units: [UnitObj] = [
        UnitObj(key: "MPS", symbol: "m/s", name: "metres per second", value: 1/3.6),
        UnitObj(key: "KMPH", symbol: "km/h", name: "kilometres per hour", value: Quantities.BASE),
        UnitObj(key: "MPH", symbol: "mph", name: "miles per hour", value: 1/1.609344),
        UnitObj(key: "KTS", symbol: "kts", name: "knots", value: 1/1.852),
        UnitObj(key: "FTPS", symbol: "ft/s", name: "feet per second", value: 1/1.09728),
        UnitObj(key: "C", symbol: "c", name: "speed of light", value: 1/(299792458*3.6))
    ]

}
