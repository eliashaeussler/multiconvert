//
//  MCError.swift
//  MultiConvert
//
//  Created by Elias Häußler on 18.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

enum MCError: Error
{
    case noConnection
    case noData
    
    case noCompatibleQuantity
    case noCompatibleInputUnit
    case noCompatibleOutputUnit
    case noCompatibleUnit
    case noDifferentUnits
}
