//
//  MainViewController.swift
//  MultiConvert
//
//  Created by Elias Häußler on 02.03.17.
//  Copyright © 2017 Elias Häußler. All rights reserved.
//

import UIKit
import CoreData

class TableViewConversionCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
}

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //-- OUTLETS
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navRefresh: UIBarButtonItem!
    @IBOutlet weak var navAddFav: UIBarButtonItem!
    
    @IBOutlet weak var manualView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var quantitySegments: UISegmentedControl!
    @IBOutlet weak var inpView: UIView!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var inputUnit: UIPickerView!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var outputText: UITextField!
    @IBOutlet weak var outputUnit: UIPickerView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    

    //-- CONSTANTS
    
    /** Beautiful date format */
    static let DATE_FORMAT = "dd.MM.yyyy"
    
    /** Beautiful date and time format */
    static let DATETIME_FORMAT = "dd.MM.yyyy, HH:mm"
    
    /** Default placeholder for input text field */
    let DEFAULT_PLACEHOLDER = "Type in value to convert"
    
    
    //-- VARIABLES
    
    /** First time opening the view controller */
    var firstTime = true
    
    /** Alert controller */
    var alert: UIAlertController? = nil
    
    /** All compatible quantities */
    var quantities: [QuantityObj] = []
    
    /** Units for conversion */
    var units: [UnitObj] = []
    
    /** Quantity and Units to convert */
    var toConvert: QuantityObj? = nil
    
    /** Converted values */
    var converted: [Converter.Values] = []
    
    /** Current active text field */
    var activeInput: UITextField? = nil
    
    /** Tells if the user can add a conversion to favorites */
    var canAdd = true
    
    /** Active conversion from favorites or history */
    var activeConversion: Converter.Values? = nil
    
    
    
    //-- FUNCTIONS
    
    /** Display UIAlertController to show that the application is loading the current exchange rates */
    func showLoad()
    {
        // Dismiss alert controller
        hideLoad(animated: false, completion:
        {
            // Instantiate activity indicator view
            DispatchQueue.main.async {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                indicator.isUserInteractionEnabled = false
                indicator.startAnimating()
                
                // Instantiate alert controller
                self.alert = self.alert(title: "Updating exchange rates...", message: "Please wait a moment.", actions: nil, show: false)
                
                // Instantiate view controller
                let customVC = UIViewController()
                customVC.view.addSubview(indicator)
                
                // Set constraints
                customVC.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: customVC.view, attribute: .centerX, multiplier: 1, constant: 0))
                customVC.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: customVC.view, attribute: .centerY, multiplier: 1, constant: 0))
                
                // Set view controller for alert controller
                self.alert?.setValue(customVC, forKey: "contentViewController")
                
                // Show alert controller
                self.present(self.alert!, animated: true, completion: nil)
            }
        })
    }
    
    /** Hide active UIAlertController */
    func hideLoad(animated: Bool, completion: (() -> Void)?)
    {
        // Dismiss alert controller
        if alert != nil {
            alert?.dismiss(animated: animated, completion: {
                self.alert = nil
                if completion != nil {
                    completion!()
                }
            })
        } else if completion != nil {
            completion!()
        }
    }
    
    /** Create custom UIAlertController */
    func alert(title: String?, message: String?, actions: [UIAlertAction]?, show: Bool) -> UIAlertController?
    {
        // Instantiate alert controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add actions
        if actions != nil {
            for action in actions! {
                alert.addAction(action)
            }
        }
        
        // Dismiss and show alert controller
        if show {
            hideLoad(animated: false, completion: { 
                self.present(alert, animated: true, completion: nil)
            })
        }
        
        return alert
    }
    
    /** Update currencies while getting the latest exchange rates from fixer API */
    func updateCurrencies()
    {
        //-- BACKGROUND THREAD
        DispatchQueue.global(qos: .userInitiated).async
        {
            // Show alert controller
            self.showLoad()
            
            //-- MAIN THREAD
            DispatchQueue.main.async
            {
                // Error
                var error: MCError? = .noData
                
                // Date
                var date: Date? = nil
                
                do {
                    // Update currency rates
                    date = try Currency.update()
                    
                    // No error
                    error = nil
                    
                } catch MCError.noConnection {
                    
                    // Error: No connection
                    error = .noConnection
                    
                } catch {}
                
                // Try to get currency rates from Core Data
                do {
                    if error != nil {
                        try Currency.getFromCoreData()
                    }
                    
                    // Get units
                    try self.quantities[self.quantities.index(where: { $0.name == Quantity.Currency })!].units = Quantities.getUnits(forQuantity: Quantity.Currency, withBase: true)
                    
                    // Enable segment
                    for i in 0..<self.quantitySegments.numberOfSegments
                    {
                        if self.quantitySegments.titleForSegment(at: i) == Quantity.Currency.rawValue {
                            self.quantitySegments.setEnabled(true, forSegmentAt: i)
                        }
                    }
                } catch {}
                
                // Display alert
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                if error != nil
                {
                    switch error!
                    {
                        // No connection
                        case .noConnection:
                            _ = self.alert(title: "Update failed \u{1F631}", message: "Please check your internet connection.", actions: [action], show: true)
                            break
                            
                        // No data
                        case .noData:
                            _ = self.alert(title: "Update failed \u{1F631}", message: "Reason: No data found.", actions: [action], show: true)
                            break
                            
                        default: break

                    }
                }
                else
                {
                    // Update successful
                    _ = self.alert(title: "Update successful!", message: "Currency state: " + MainViewController.formatDate(date!, withTime: false), actions: [action], show: true)
                }
            }
        }
        
    }
    
    /** Check user's input on QuickConvert (that is, the text content presented by the search bar) */
    func checkQuickConvert(_ searchText: String) -> Double?
    {
        // Reset quantity and units for conversion
        toConvert = nil
        
        // Split user input
        var input = searchText.split { $0 == " " }.map(String.init)
        
        // Check if user typed in number and unit without whitespace in between
        for (i, inp) in input.enumerated()
        {
            // Get all numbers
            let numbers = inp.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
            
            // Insert whitespace after number
            var inp = inp
            for n in numbers {
                inp.insert(" ", at: (inp.range(of: n)?.upperBound)!)
            }
            input[i] = inp.trimmingCharacters(in: CharacterSet.whitespaces)
        }
        
        // Split input again to separate numbers from units
        for i in 0..<input.count
        {
            // Split input segment
            let splitted = input[i].components(separatedBy: " ")
            
            // Check if segment contains whitespaces
            if splitted.count > 1
            {
                // Insert splitted characters into original input
                for n in 1..<splitted.count {
                    input.insert(splitted[n], at: i+n)
                }
                
                // Change current input segment
                input[i] = splitted[0]
            }
        }
        
        // Check user input for units and numbers
        var number: Double? = nil
        
        for i in input
        {
            // Check for numberes
            var nr: Double = 0
            if isNumber(i, number: &nr) && number == nil {
                number = nr
            }
                
            // Check for units
            else
            {
                for q in quantities
                {
                    // Get unit object index
                    let unit = q.units.index(where: { $0.key.uppercased() == i.uppercased() })
                    
                    // Check if unit is found and can be added
                    if (
                        unit != nil &&
                        (
                            toConvert == nil ||
                            (
                                toConvert!.name == q.name &&
                                !(toConvert?.units.contains(where: { $0.key == q.units[unit!].key }))!
                            )
                        )
                    ) {
                        // Instantiate quantity object for conversion
                        if toConvert == nil {
                            toConvert = QuantityObj(name: q.name, units: [])
                        }
                        
                        // Add unit for conversion
                        toConvert?.units.append( q.units[q.units.index(where: { $0.key.uppercased() == i.uppercased() })!] )
                    }
                }
            }
        }
        
        return number
    }
    
    /** Convert a given input to the selected quantity and units. Has the option to convert the given value to all units presented by the selected quantity */
    func doConversion(for input: Double, fromQuickConvert convertAll: Bool)
    {
        // Reset converted values
        converted = []
        
        if toConvert != nil && (toConvert?.units.count)! > 0
        {
            // Get input unit
            let base = toConvert?.units[0]
            
            if (toConvert?.units.count)! > 1
            {
                // Do conversion
                for (i, unit) in (toConvert?.units.enumerated())!
                {
                    do {
                        // Conversion
                        let result = try Converter.convert(input, quantity: toConvert!, from: base!, to: unit)
                        converted.append(result)
                        
                        // Add conversion to history (only last conversion)
                        if i+1 == toConvert?.units.endIndex
                        {
                            // Get CoreData context
                            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                            
                            // Get latest history data
                            var history = HistoryViewController.getHistory(context: context)
                            
                            // Add to CoreData
                            if let quantityName = toConvert?.name.rawValue
                            {
                                if !(history.count > 0 && history[0].quantity == quantityName && history[0].inputUnit == base?.key && history[0].outputUnit == unit.key)
                                {
                                    // Save conversion
                                    let conversion = History(context: context)
                                    conversion.date = NSDate()
                                    conversion.input = input
                                    conversion.inputUnit = base?.key
                                    conversion.outputUnit = unit.key
                                    conversion.quantity = quantityName
                                    
                                    // Save to Core Data
                                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                                }
                            }
                            
                            // Get updated history
                            history = HistoryViewController.getHistory(context: context).reversed()
                            let remaining = history.count - HistoryViewController.HISTORY_MAX
                            
                            // Delete old history data
                            if remaining > 0
                            {
                                for (i, conversion) in history.enumerated()
                                {
                                    if i >= remaining {
                                        break
                                    }
                                    
                                    context.delete(conversion)
                                }
                            }
                        }
                    }
                    
                    // No compatible input unit
                    catch MCError.noCompatibleInputUnit {
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        _ = alert(title: "Sorry, you failed \u{1F606}", message: "You can't use this base unit for conversion.", actions: [action], show: true)
                    }
                    
                    // No compatible output unit
                    catch MCError.noCompatibleOutputUnit {
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        _ = alert(title: "Sorry, you failed \u{1F606}", message: "You can't use this target unit for conversion.", actions: [action], show: true)
                    }
                        
                    // No different units
                    catch MCError.noDifferentUnits {}
                        
                    // No compatible quantity
                    catch MCError.noCompatibleQuantity {
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        _ = alert(title: "Sorry, you failed \u{1F606}", message: "You can't use this quantity for conversion.", actions: [action], show: true)
                    }
                        
                    // Another exception
                    catch {}
                }
            }
            
            // Convert to all units
            if convertAll
            {
                // Get units
                if let units = try? Quantities.getUnits(forQuantity: (toConvert?.name)!, withBase: true)
                {
                    for unit in units
                    {
                        // Conversion
                        if !toConvert!.units.contains(unit)
                        {
                            if let result = try? Converter.convert(input, quantity: toConvert!, from: base!, to: unit) {
                                converted.append(result)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /** Check conversion for a given UITextField and proceed to conversion if input is legal */
    func checkConversion(for sender: UITextField)
    {
        if toConvert != nil
        {
            // Reset units for conversion
            toConvert?.units = []
            
            // Set output
            var out = outputText
            var inpUnit = inputUnit
            var outUnit = outputUnit
            
            if sender != inputText {
                out = inputText
                inpUnit = outputUnit
                outUnit = inputUnit
            }
            
            // Get input and output unit
            toConvert?.units.append(units[inpUnit!.selectedRow(inComponent: 0)])
            toConvert?.units.append(units[outUnit!.selectedRow(inComponent: 0)])
            
            // Do conversion
            var number: Double = 0
            if isNumber(sender.text!, number: &number)
            {
                // Conversion
                doConversion(for: number, fromQuickConvert: false)
                
                // Display converted value
                if converted.count > 0 {
                    out!.text = String(describing: converted[0].output!)
                }
            } else {
                out!.text = sender.text!.count > 0 ? "Error" : ""
            }
        }
    }
    
    /** Clear all data of the UITableView */
    func clearTableView()
    {
        // Reset quantity and units
        segmentChanged(quantitySegments)
        
        // Reset converted values
        converted = []
        
        // Update table view
        tableView.reloadData()
    }
    
    /** Initialize UISegmentedControl and add quantities to segments */
    func initSegments()
    {
        // Remove all segments
        quantitySegments.removeAllSegments()
        
        // Insert segments
        for (i, q) in quantities.enumerated()
        {
            quantitySegments.insertSegment(withTitle: q.name.rawValue, at: i, animated: false)
            
            if !Quantities.exists(q.name) {
                quantitySegments.setEnabled(false, forSegmentAt: i)
            }
        }
        
        // Define and set active segment and quantity
        let active = 0
        quantitySegments.selectedSegmentIndex = active
        toConvert = QuantityObj(name: quantities[active].name, units: [])
        
        // Do segment change
        segmentChanged(quantitySegments)
    }
    
    /** Update units for selected quantity */
    func updateUnits()
    {
        // Set units
        units = (try? Quantities.getUnits(forQuantity: (toConvert?.name)!, withBase: true)) ?? []
        
        // Update picker view
        inputUnit.reloadAllComponents()
        outputUnit.reloadAllComponents()
        
        // Set units
        let base = try? units.index(where: { try $0 == Quantities.getBase(forQuantity: (toConvert?.name)!) }) ?? 0
        let target = base != 0 ? 0 : 1
        inputUnit.selectRow(base!, inComponent: 0, animated: false)
        outputUnit.selectRow(target, inComponent: 0, animated: false)
    }
    
    /** Check if another UIViewController sent an active conversion to this UIViewController and handle it */
    func checkActiveConversion()
    {
        if activeConversion != nil
        {
            var showAlert = false
            for (i, q) in quantities.enumerated()
            {
                if q == (activeConversion?.quantity)!
                {
                    // Set quantity
                    quantitySegments.selectedSegmentIndex = i
                    
                    if quantitySegments.isEnabledForSegment(at: i)
                    {
                        // Clear search bar
                        searchBar.text = ""
                        searchBar(searchBar, textDidChange: "")
                        
                        // Set units
                        var inputFound = false
                        var outputFound = false
                        
                        for (n, u) in q.units.enumerated()
                        {
                            if u == activeConversion?.inputUnit {
                                inputUnit.selectRow(n, inComponent: 0, animated: true)
                                inputFound = true
                            }
                            if u == activeConversion?.outputUnit {
                                outputUnit.selectRow(n, inComponent: 0, animated: true)
                                outputFound = true
                            }
                        }
                        
                        if inputFound && outputFound
                        {
                            // Set active input
                            activeInput = inputText
                            
                            // Do conversion
                            checkConversion(for: activeInput!)
                            
                            // Focus input text field
                            activeInput!.becomeFirstResponder()
                        }
                        else
                        {
                            showAlert = true
                        }
                    }
                    else
                    {
                        showAlert = true
                    }
                    
                    break
                }
            }
            
            // Show alert if conversion was not found
            if showAlert
            {
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                _ = alert(title: "Oh no! \u{1F625}", message: "This conversion is no longer available.", actions: [action], show: true)
            }
            
            // Unset active conversion
            activeConversion = nil
        }
    }
    
    
    
    //-- UI INTERACTION FUNCTIONS
    
    /** Update exchange rates for currencies when user presses the refresh button in UINavigationBar */
    @IBAction func navRefreshPressed(_ sender: UIBarButtonItem) {
        updateCurrencies()
    }
    
    /** Add active conversion to favorites when user presses the add button in UINavigationBar */
    @IBAction func navAddPressed(_ sender: UIBarButtonItem)
    {
        if canAdd
        {
            if toConvert != nil && (toConvert?.units.count)! > 1 && toConvert?.units[0] != toConvert?.units[1]
            {
                // Check if user converted via QuickConvert
                let isQuickConvert = (toConvert?.units.count)! > 2
                
                // Get base and target unit
                let base = toConvert?.units.first
                let target = isQuickConvert ? toConvert?.units[tableView.numberOfRows(inSection: 0)] : toConvert?.units.last
                
                // Get CoreData context
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                // Get favorites data
                let favorites = FavoritesViewController.getFavorites(context: context)
                
                // Add to CoreData
                var isExisting = false
                for fav in favorites
                {
                    if fav.quantity == toConvert?.name.rawValue && fav.inputUnit == base?.key && fav.outputUnit == target?.key {
                        isExisting = true
                        break
                    }
                }
                
                if !isExisting
                {
                    // Save favorite
                    let conversion = Favorite(context: context)
                    conversion.inputUnit = base?.key
                    conversion.outputUnit = target?.key
                    conversion.quantity = toConvert?.name.rawValue
                    
                    // Save to Core Data
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    
                    // Show alert
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    _ = alert(title: "Success! \u{1F917}", message: "Conversion was successfully added to your favorites list.", actions: [action], show: true)
                }
                else
                {
                    // Conversion is already favorite
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    _ = alert(title: "You already \u{2764} it!", message: "This conversion is already in your favorites list.", actions: [action], show: true)
                }
            }
        }
        else
        {
            // Change nav bar button
            let button = UIBarButtonItem(barButtonSystemItem: .add, target: navAddFav.target, action: navAddFav.action)
            navBar.topItem?.rightBarButtonItem = button
            
            // Update nav bar button
            navAddFav = button
            
            // Hide keyboard
            view.endEditing(true)
            
            // User can now add conversion to favorites
            canAdd = true
        }
    }
    
    /** Change quantity and UI elements when user changes the active segment in UISegmentedControl */
    @IBAction func segmentChanged(_ sender: UISegmentedControl)
    {
        // Set active quantity
        let q = quantities[sender.selectedSegmentIndex]
        toConvert = QuantityObj(name: q.name, units: [])
        
        // Update placeholder
        do {
            inputText.placeholder = try "e.g. " + Quantities.getPlaceholder(forQuantity: q.name)
        } catch {
            inputText.placeholder = DEFAULT_PLACEHOLDER
        }
        
        // Update units
        updateUnits()
        
        // Update conversion
        checkConversion(for: inputText)
    }
    
    /** Return the number of components in UIPickerView */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /** Return the number of rows in UIPickerView */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return units.count
    }
    
    /** Return the title for a given row in UIPickerView */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return units[row].name
    }
    
    /** Check conversion if user changes the selected row in UIPickerView */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if activeInput != nil {
            checkConversion(for: activeInput!)
        }
    }
    
    /** Check conversion if user changed the text content of UITextField */
    @IBAction func inputTextChanged(_ sender: UITextField) {
        checkConversion(for: sender)
    }
    
    /** Set active input field and change UINavigationBar items when user starts typing in UITextField */
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        // Set active input
        activeInput = textField
        
        // Change nav bar button
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: navAddFav.target, action: navAddFav.action)
        navBar.topItem?.rightBarButtonItem = button
        
        // Update nav bar button
        navAddFav = button
        
        // User cannot add conversion to favorites
        canAdd = false
    }
    
    /** Check conversion or hide UITableView if user changes the text content of UISearchBar */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        // Change nav bar button
        searchBarTextDidBeginEditing(searchBar)
        
        // Show or hide manual view
        manualView.isHidden = searchText.count > 0
        
        // Show or hide cancel button
        searchBar.setShowsCancelButton(searchText.count > 0, animated: true)
        
        if searchText.count > 0
        {
            // Check if user input contains logical input
            let input = checkQuickConvert(searchText) ?? 1
            
            // Start conversion
            doConversion(for: input, fromQuickConvert: true)
        }
        else
        {
            // Update quantity
            segmentChanged(quantitySegments)
        }
        
        // Update table view
        tableView.reloadData()
    }
    
    /** Hides the UITableView when user clicks the cancel button in UISearchBar */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        // Clear user input
        searchBar.text = ""
        
        // Show manual view
        manualView.isHidden = false
        
        // Hide cancel button
        searchBar.setShowsCancelButton(false, animated: true)
        
        // Hide keyboard
        view.endEditing(true)
        
        // Clear table view
        clearTableView()
        
        // Update quantity
        segmentChanged(quantitySegments)
    }
    
    /** Hide keyboard if user presses search button in UISearchBar */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    /** Change item of UINavigationBar if users starts typing into UISearchBar */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        // Change nav bar button
        let navItem: UIBarButtonSystemItem = (searchBar.text?.count)! > 0 ? .add : .done
        let button = UIBarButtonItem(barButtonSystemItem: navItem, target: navAddFav.target, action: navAddFav.action)
        navBar.topItem?.rightBarButtonItem = button
        
        // Update nav bar button
        navAddFav = button
        
        // User can add conversion to favorites
        canAdd = (searchBar.text?.count)! > 0
    }
    
    /** Return number of sections in UITableView */
    func numberOfSections(in tableView: UITableView) -> Int {
        return toConvert != nil && (toConvert?.units.count)! > 1 ? ((toConvert?.units.count)! < converted.count ? 2 : 1) : 1
    }
    
    /** Return title for given section in UITableView */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section {
            case 0:
                return toConvert == nil || (toConvert?.units.count)!-1 < 1 ? nil : "Your conversions"
            case 1:
                return "All conversions"
            default:
                return nil
        }
    }
    
    /** Return number of rows in given section of UITableView */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let count = toConvert != nil ? (toConvert?.units.count)!-1 : 0
        let allCount = converted.count - count
        switch section {
            case 0:
                return count < 1 ? allCount : count
            case 1:
                return allCount
            default:
                return 0
        }
    }
    
    /** Return cell for given row in UITableView */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Instantiate table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversionCell", for: indexPath) as! TableViewConversionCell
        
        if converted.count > 0
        {
            // Load data
            let data = converted[indexPath.section == 0 ? indexPath.row : tableView.numberOfRows(inSection: 0)+indexPath.row]
            
            // Edit data
            let quantity = (data.quantity?.name)!
            let input = String(describing: data.input!)
            let inputUnit = (data.inputUnit?.name)!
            let output = String(describing: data.output!)
            let outputSymbol = (data.outputUnit?.symbol)!
            let outputUnit = (data.outputUnit?.name)!
            
            // Append data on table view cell
            cell.titleLabel.text = output + " " + outputSymbol
            cell.subtitleLabel.text = "\(input) \(inputUnit) \u{2192} \(outputUnit) \u{00B7} \(quantity)"
        }
        
        return cell
    }
    
    /** Define that user cannot focus rows at UITableView */
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    
    //-- FORMAT & CHECK
    
    /** Returns given date in beautiful date and (optionally) also time format */
    static func formatDate(_ date: Date, withTime time: Bool) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = time ? DATETIME_FORMAT : DATE_FORMAT
        
        return dateFormatter.string(from: date) + (time ? "h" : "")
    }
    
    /** Check if input string is convertable to a number */
    func isNumber(_ string: String, number:inout Double) -> Bool
    {
        // Trim whitespaces
        var string = string.replacingOccurrences(of: " ", with: "")
        
        // Replace comma
        string = string.replacingOccurrences(of: ",", with: ".")
        
        // Convert
        if Double(string) == nil {
            number = 0
            return false
        } else {
            number = Double(string)!
            return true
        }
    }
    
    

    //-- DEFAULT LOADING ACTIONS

    /** Setup UI after view did load */
    override func viewDidLoad()
    {
        // Default loading
        super.viewDidLoad()
        
        // Set up delegates
        searchBar.delegate = self
        tableView.delegate = self
        inputText.delegate = self
        inputUnit.delegate = self
        outputText.delegate = self
        outputUnit.delegate = self
        scrollView.delegate = self
        
        // Set up data sources
        tableView.dataSource = self
        inputUnit.dataSource = self
        outputUnit.dataSource = self
        
        // Load quantities
        quantities = Quantities.getQuantities()
        
        // Initialize segments
        initSegments()
        
        // Set active input
        activeInput = inputText
        
        // Set layout of views
        inpView.layer.cornerRadius = 10
        outView.layer.cornerRadius = 10
    }
    
    /** Update currency exchange rates at the first time and check for active conversions after view did appear */
    override func viewDidAppear(_ animated: Bool)
    {
        // Default action
        super.viewDidAppear(animated)
        
        if firstTime
        {
            // Update currencies
            updateCurrencies()
            
            // Do not update again
            firstTime = false
        }
        
        // Set conversion values
        checkActiveConversion()
        
        // Register keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    
    //-- OBSERVER FUNCTIONS
    
    /** Change constraints of UIScrollView and UITableView when keyboard did show */
    @objc func keyboardDidShow(notification: NSNotification)
    {
        // Get user info
        let userInfo = notification.userInfo! as NSDictionary
        
        // Get keyboard info
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue
        
        // Get insets
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - (tabBarController?.tabBar.frame.size.height)!, right: 0)
        
        // Apply insets
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    /** Reset contraints of UIScrollView and UITableView after keyboard did hide */
    @objc func keyboardWillHide(notification: NSNotification)
    {
        // Reset insets
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        tableView.contentInset = UIEdgeInsets.zero
        tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

}
