//
//  HistoryViewController.swift
//  MultiConvert
//
//  Created by Elias Häußler on 17.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit
import CoreData

class TableViewHistoryCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
}

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //-- OUTLETS
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navDelete: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //-- CONSTANTS
    
    /** Maximum of displayed elements in history */
    static let HISTORY_MAX = 20
    
    
    
    //-- VARIABLES
    
    /** History data, converted from CoreData into usable objects */
    var histCD: [History] = []
    
    /** History data, read from CoreData */
    var history: [ConversionObj] = []
    
    
    
    //-- FUNCTIONS
    
    /** Get history data from CoreData and return them */
    static func getHistory(context: NSManagedObjectContext) -> [History]
    {
        // Fetch history data
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        
        // Read data
        do {
            return (try context.fetch(fetch) as! [History]).sorted(by: { $0.0.date?.compare($0.1.date! as Date) == .orderedDescending })
        } catch {
            return []
        }
    }
    
    /** Clear history data from UITableView and CoreData */
    func clearHistory()
    {
        // Get CD Context
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Clear history
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        
        if let history = try? context.fetch(fetch)
        {
            for conversion in history {
                let obj = conversion as! NSManagedObject
                context.delete(obj)
                try? context.save()
            }
        }
        
        // Reset history
        histCD = []
        history = []
        
        // Reload table view
        tableView.reloadData()
        
        // Disable trash button
        navDelete.isEnabled = false
    }
    
    
    
    //-- UI INTERACTION FUNCTIONS
    
    /** Return number of sections in UITableView */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /** Return number of rows in UITableView */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    /** Define cell for given row in UITableView */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Instantiate table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! TableViewHistoryCell
        
        // Load data
        let data = history[indexPath.row].conversion[0]
        
        // Append data on table view cell
        cell.titleLabel.text = (data.inputUnit?.name)! + " \u{2192} " + (data.outputUnit?.name)!
        cell.subtitleLabel.text = MainViewController.formatDate(data.date, withTime: true) + " \u{00B7} " + (data.quantity?.name.rawValue)!
        
        return cell
    }
    
    /** Send selected conversion from UITableView to MainViewController */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Get a reference to ViewController
        let viewController = tabBarController?.viewControllers?[0] as! MainViewController
        
        // Set conversion
        let indexPath = tableView.indexPathForSelectedRow!
        viewController.activeConversion = history[indexPath.row].conversion[0]
        
        // Change ViewController
        tabBarController?.selectedIndex = 0
    }
    
    /** Reset history when user presses item in UINavigationBar */
    @IBAction func navDeleteClicked(_ sender: UIBarButtonItem)
    {
        // Alert
        let alert = UIAlertController(title: "Clear history \u{1F4A8}", message: "Do you really want to clear all conversions in your history? This can't be undone.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) in self.clearHistory() }))
        show(alert, sender: self)
    }
    
    

    //-- DEFAULT LOADING FUNCTIONS
    
    /** Setup delegates and data sources after view did load */
    override func viewDidLoad()
    {
        // Default loading
        super.viewDidLoad()
        
        // Set up delegates
        tableView.delegate = self
        
        // Set up data sources
        tableView.dataSource = self
    }
    
    /** Get history data from CoreData after view did appear */
    override func viewDidAppear(_ animated: Bool)
    {
        // Get CD Context
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Fetch history data from CoreData
        histCD = HistoryViewController.getHistory(context: context)
        
        // Reset history
        history = []
        
        // Set conversions
        for h in histCD {
            let quantity = Quantities.getQuantity(forString: h.quantity!)!

            if let inpIndex = quantity.units.index(where: { $0.key == h.inputUnit! }),
                let outIndex = quantity.units.index(where: { $0.key == h.outputUnit! })
            {
                let conversion = Converter.Values(quantity: quantity, inputUnit: quantity.units[inpIndex], outputUnit: quantity.units[outIndex], input: h.input)
                conversion.date = h.date! as Date
                history.append(ConversionObj(quantity: quantity, conversion: [conversion]))
            }
        }
        
        // Reload table view
        tableView.reloadData()
        
        // Enable or disable trash button
        navDelete.isEnabled = history.count > 0
    }

}
