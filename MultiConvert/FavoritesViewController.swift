//
//  FavoritesViewController.swift
//  MultiConvert
//
//  Created by Elias Häußler on 17.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //-- OUTLETS
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navDelete: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //-- VARIABLES
    
    /** Favorites data, converted from CoreData into usable objects */
    var favCD: [Favorite] = []
    
    /** Favorites data, read from CoreData */
    var favorites: [ConversionObj] = []
    
    
    
    //-- FUNCTIONS
    
    /** Get favorites data from CoreData and return them */
    static func getFavorites(context: NSManagedObjectContext) -> [Favorite]
    {
        // Fetch favorites data
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        
        // Read data
        do {
            return (try context.fetch(fetch) as! [Favorite]).sorted(by: { $0.quantity!.compare($1.quantity!) == .orderedAscending })
        } catch {
            return []
        }
    }
    
    
    
    //-- UI INTERACTION FUNCTIONS
    
    /** Return number of sections in UITableView */
    func numberOfSections(in tableView: UITableView) -> Int {
        return favorites.count
    }
    
    /** Return number of rows in given section of UITableView */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites[section].conversion.count
    }
    
    /** Return title for given section in UITableView */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return favorites[section].quantity.name.rawValue
    }
    
    /** Define and return cell for given row in UITableView */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Instantiate table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath)
        
        // Get data
        let data = favorites[indexPath.section].conversion[indexPath.row]
        
        // Append data on table view cell
        cell.textLabel!.text = (data.inputUnit?.name)! + " \u{2192} " + (data.outputUnit?.name)!
        
        return cell
    }
    
    /** Send selected conversion from UITableView to MainViewController */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Get a reference to ViewController
        let viewController = tabBarController?.viewControllers?[0] as! MainViewController
        
        // Set conversion
        let indexPath = tableView.indexPathForSelectedRow!
        viewController.activeConversion = favorites[indexPath.section].conversion[indexPath.row]
        
        // Change ViewController
        tabBarController?.selectedIndex = 0
    }
    
    /** Delete selected conversion from UITableView in CoreData */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            // Get conversion from favorites
            var fav = favorites[indexPath.section]
            let conversion = fav.conversion[indexPath.row]
            
            // Get CD Context
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            // Delete element from Core Data
            if let index = favCD.index(where: { $0.quantity! == fav.quantity.name.rawValue && $0.inputUnit! == conversion.inputUnit?.key && $0.outputUnit! == conversion.outputUnit?.key })
            {
                context.delete(favCD[index])
                try? context.save()
            }
            
            // Delete element(s) from array
            if fav.conversion.count > 1 {
                favorites[indexPath.section].conversion.remove(at: indexPath.row)
            } else {
                favorites.remove(at: indexPath.section)
            }
            
            // Update table view
            tableView.reloadData()
            
            // Change nav bar button
            if favorites.count == 0 {
                navDeleteClicked(navDelete)
            }
        }
    }
    
    /** Enable deletion for rows in UITableView when user presses item in UINavigationBar */
    @IBAction func navDeleteClicked(_ sender: UIBarButtonItem)
    {
        if !tableView.isEditing
        {
            // Change nav bar button
            let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: sender.target, action: sender.action)
            navBar.topItem?.rightBarButtonItem = button
            
            // Update nav bar button
            navDelete = button
        }
        else
        {
            // Change nav bar button back
            let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: sender.target, action: sender.action)
            navBar.topItem?.rightBarButtonItem = button
            
            // Update nav bar button
            navDelete = button
        }
        
        // Enable oder disable table view editing
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        // Enable or disable trash button
        navDelete.isEnabled = favorites.count > 0
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
    
    /** Get favories data from CoreData after view did appear */
    override func viewDidAppear(_ animated: Bool)
    {
        // Get CD Context
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Fetch favorites data from CoreData
        favCD = FavoritesViewController.getFavorites(context: context)
        
        // Reset favorites
        favorites = []
        
        // Get quantities
        for f in favCD {
            if !favorites.contains(where: { $0.quantity.name.rawValue == f.quantity! }) {
                favorites.append(ConversionObj(quantity: Quantities.getQuantity(forString: f.quantity!)!, conversion: []))
            }
        }
        
        // Get conversions
        for f in favCD
        {
            let quantity = Quantities.getQuantity(forString: f.quantity!)!
            
            if let conversion = try? Converter.Values(quantity: Quantities.getQuantity(forObject: quantity.name), inputUnit: Quantities.getUnit(f.inputUnit!, forQuantity: quantity.name)!, outputUnit: Quantities.getUnit(f.outputUnit!, forQuantity: quantity.name)!, input: 0.0)
            {
                favorites[favorites.index(where: { $0.quantity == quantity })!].conversion.append(conversion)
            }
        }
        
        // Clear empty sections
        for (i, fav) in favorites.enumerated()
        {
            if fav.conversion.count == 0 {
                favorites.remove(at: i)
            }
        }
        
        // Reload table view
        tableView.reloadData()
        
        // Enable or disable trash button
        navDelete.isEnabled = favorites.count > 0
    }

}
