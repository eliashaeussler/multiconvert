//
//  QuantityProtocol.swift
//  MultiConvert
//
//  Created by Elias Häußler on 25.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit
import Foundation

protocol QuantityProtocol
{
    /** UI elements */
    static var placeholder: String { get }
    
    /** Units */
    static var units: [UnitObj] { get set }
}
