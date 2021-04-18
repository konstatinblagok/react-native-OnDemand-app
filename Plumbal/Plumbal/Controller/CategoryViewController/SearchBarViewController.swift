//
//  SearchBarViewController.swift
//  Plumbal
//
//  Created by Casperon iOS on 15/12/2016.
//  Copyright © 2016 Casperon Tech. All rights reserved.
//

import UIKit



class SearchBarViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var countryTable: UITableView!
    @IBOutlet weak var countrySearchController: UISearchBar!
    
    var searchArray = [String]()
    
    //MARK: - Override Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = PlumberThemeColor
        countryTable.delegate = self
        countryTable.dataSource = self
        countryTable.reload()
        
        countrySearchController.showsCancelButton = true
        countrySearchController.text = ""
        countrySearchController.isSearchResultsButtonSelected = true
        countrySearchController.delegate = self
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState())
        countrySearchController.barTintColor = PlumberThemeColor
        for subView in countrySearchController.subviews {
            for secondLevelSubview in subView.subviews{
                if (secondLevelSubview.isKind(of: UITextField.self)) {
                    if let searchBarTextField:UITextField = secondLevelSubview as? UITextField  {
                        searchBarTextField.becomeFirstResponder()
                        searchBarTextField.placeholder = "Search"
                        searchBarTextField.textColor = PlumberThemeColor
                        break;
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(countrySearchController.text != ""){
            return searchArray.count
        }else{
            return themes.codename.count;
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = countryTable.dequeueReusableCell(withIdentifier: "Cell") as! SearchBarTableViewCell
        cell.textLabel?.text = ""
      //  var font = UIFont.init(name: plumberMediumFont, size: <#T##CGFloat#>)
        cell.textLabel?.font = PlumberMediumFont
        cell.textLabel?.attributedText = NSAttributedString(string: "")
        
        if(countrySearchController.text != "")  {
           cell.configureCellWith(searchTerm:countrySearchController.text!, cellText: searchArray[indexPath.row])
            return cell
        }else{
            cell.textLabel?.text! = themes.codename[indexPath.row] as! String
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if(searchArray.count == 0){
            countrySearchController.text = themes.codename[indexPath.row] as? String
            signup.selectedCode = themes.codename[indexPath.row] as! String

        }else{
            countrySearchController.text = searchArray[indexPath.row]
            signup.selectedCode = searchArray[indexPath.row]

        }
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewControllerWithFlip(animated: true)
    }
    
    //MARK: - SearchBar Delegate
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        let NewText = (searchBar.text! as NSString).replacingCharacters(in: range, with:text)
        print(NewText);
        if !NewText.contains("\n") && NewText != "" {
            searchArray.removeAll(keepingCapacity: false)

         let range = (NewText as String).startIndex ..< (NewText as String).endIndex
        var searchString = String()
        (NewText as String).enumerateSubstrings(in: range, options: .byComposedCharacterSequences, { (substring, substringRange, enclosingRange, success) in
            searchString.append(substring!)
            searchString.append("*")
        })
        let searchPredicate = NSPredicate(format: "SELF LIKE[c] %@", searchString)
        let array = (themes.codename as NSArray).filtered(using: searchPredicate)
        searchArray = array as! [String]

        countryTable.reload()
        return true
        }
        if NewText == ""{

            countryTable.reload()
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewControllerWithFlip(animated: true)
    }
    
}
