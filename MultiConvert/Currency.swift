//
//  Currency.swift
//  MultiConvert
//
//  Created by Elias Häußler on 02.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit
import CoreData

class Currency: NSObject, QuantityProtocol {
    
    //-- CONSTANTS
    
    /** API url to catch latest currencies */
    static let API_URL = "https://api.fixer.io/latest"
    
    /** API keys for section rates */
    static let API_KEY_RATES = "rates"
    
    /** API keys for section date */
    static let API_KEY_DATE = "date"
    
    /** API keys for section base */
    static let API_KEY_BASE = "base"
    
    /** API update date format */
    static let API_DATE_FORMAT = "yyyy-MM-dd"
    
    /** UI elements */
    static let placeholder = "45.99"
    
    
    //-- VARIABLES
    
    /** JSON currency data */
    static var jsonData: Data? = nil
    
    /** Update date */
    static var date: Date? = nil
    
    /** Units */
    static var units: [UnitObj] = []
    
    
    
    //-- FUNCTIONS
    
    /** Get latest exchange rates from fixer API and save them into CoreData */
    static func update() throws -> Date?
    {
        do
        {
            // Read json data
            try jsonData = Data(contentsOf: URL(string: API_URL)!)
            
            // Convert json data
            guard let json = try? JSONSerialization.jsonObject(with: jsonData!, options: []) else {
                throw MCError.noData
            }
            
            // Read json data values
            if let jsonResult = json as? [String: Any]
            {
                // Reset units
                units = []
                
                // Update date
                if let jsonDate = jsonResult[API_KEY_DATE] as? String
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = API_DATE_FORMAT
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    date = dateFormatter.date(from: jsonDate)
                }
                
                // Base currency
                if let jsonBase = jsonResult[API_KEY_BASE] as? String {
                    units.append( UnitObj(key: jsonBase, symbol: jsonBase, name: jsonBase, value: Quantities.BASE) )
                }
                
                // Currency rates and symbols
                if let jsonRates = jsonResult[API_KEY_RATES] as? [String: Any]
                {
                    // Get units
                    for (currency, rate) in jsonRates {
                        units.append( UnitObj(key: currency, symbol: currency, name: currency, value: rate as! Double) )
                    }
                }
            }
            
            // Sort units
            units = units.sorted(by: { $0 < $1 })
            
            // Write to Core Data
            write()
            
            return date
        }
        catch
        {
            // No internet connection established
            throw MCError.noConnection
        }
    }
    
    /** Write fetched exchange rates into CoreData and delete old data */
    private static func write()
    {
        // Get CD Context
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Delete rates
        let fetchCurr = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRate")
        
        if let rates = try? context.fetch(fetchCurr)
        {
            for rate in rates {
                context.delete(rate as! NSManagedObject)
                try? context.save()
            }
        }
        
        // Delete settings
        let fetchSett = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencySettings")
        
        if let settings = try? context.fetch(fetchSett)
        {
            for sett in settings {
                context.delete(sett as! NSManagedObject)
                try? context.save()
            }
        }
        
        // Save exchange rates
        for currency in units
        {
            if currency.value != Quantities.BASE
            {
                let newRate = CurrencyRate(context: context)
                newRate.currency = currency.key
                newRate.rate = currency.value
                
                // Save to Core Data
                try? context.save()
            }
        }
        
        // Save base and settings
        let settings = CurrencySettings(context: context)
        settings.base = try? Quantities.getBase(forQuantity: Quantity.Currency).key
        settings.date = date as NSDate?
        
        // Save to Core Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    /** Read units and exchange rates from CoreData */
    static func getFromCoreData() throws
    {
        // Get CD Context
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Fetch currency data
        let fetchCurr = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRate")
        let fetchSett = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencySettings")
        
        // Get exchange rates and settings
        let rates = try? context.fetch(fetchCurr) as! [CurrencyRate]
        let settings = try? context.fetch(fetchSett) as! [CurrencySettings]
        
        // Read and save exchange rates and settings
        if rates != nil && settings != nil
        {
            // Reset units
            units = []
            
            if let setting = settings?.first
            {
                // Add base unit
                units.append( UnitObj(key: setting.base!, symbol: setting.base!, name: setting.base!, value: Quantities.BASE) )
                
                // Add exchange rates
                for rate in rates! {
                    units.append( UnitObj(key: rate.currency!, symbol: rate.currency!, name: rate.currency!, value: rate.rate) )
                }
                
                // Sort units
                units = units.sorted(by: { $0 < $1 })
                
                // Set date
                date = setting.date as Date?
                
                return
            }
        }
        
        throw MCError.noData
    }
    
}
