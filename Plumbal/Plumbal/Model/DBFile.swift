//
//  DBFile.swift
//  CoredataLibrary
//
//  Created by CASPERON on 01/08/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
import CoreData

class DBFile: NSObject {

    var managedObjectContext: NSManagedObjectContext!
    var appDelegate : AppDelegate!
  var dictValues : NSMutableDictionary!
    var dataArray : NSMutableArray!
    
    
    
    
    
    func saveData(_ entityName: String, ValueStr valueArr:NSMutableArray) {
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        self.managedObjectContext = appDelegate.managedObjectContext
        //Setting Entity to be Queried
        if valueArr.count > 0 {
            for i in 0..<valueArr.count {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                //Setting Entity to be Queried
                let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
                request.entity = entity
                let pred: NSPredicate = NSPredicate(format:"providerid=%@", (valueArr[i] as AnyObject).value(forKey: "providerid") as! String)
                request.predicate = pred
               let error: NSError? = nil
                let matches: NSArray = try! managedObjectContext.fetch(request) as NSArray
                if (entityName == "Provider_Table") {
                    if  (matches.count >= 1) || error != nil {
                        // Abnormal
                        print("Error accessing database:")
                    }
                    else if 0 == matches.count {
                        
                        if ((matches.value(forKey: "providerid") as AnyObject).contains((valueArr[i] as AnyObject).value(forKey: "providerid")!)) {
                            //notify duplicates
                            NSLog("does not allow duplicates")

                            return;
                         }
                        else
                        {
                           let new: Providertable = NSEntityDescription.insertNewObject(forEntityName: entityName, into:managedObjectContext) as! Providertable
                            new.providerid = (valueArr[i] as AnyObject)["providerid"] as! String
                            do {
                                try managedObjectContext.save()
                            } catch let error {
                                print("Could not cache the response \(error)")
                            }                }
                           }
                        }
                       
            }
        }
        
}

    
    
    
func arr(_ entityName: String) -> NSMutableArray {
    
    appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    self.managedObjectContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    dictValues = NSMutableDictionary()
        //Setting Entity to be Queried
    let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
    
    
    fetchRequest.entity = entity
    
    
    dataArray = NSMutableArray()
    
    let results: NSArray = try! self.managedObjectContext.fetch(fetchRequest) as NSArray
    for data  in results as! [Providertable]  {
        dictValues = NSMutableDictionary ()
        dictValues["providerid"] = data.providerid as String
       
        dataArray.add(dictValues)
        dictValues = nil
    }

    return dataArray
    
    }
    
    func UpdateData (_ updateval:String ) {
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        self.managedObjectContext = appDelegate.managedObjectContext
        //Setting Entity to be Queried
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Provider_Table")
        //Setting Entity to be Queried
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Provider_Table", in: self.managedObjectContext)!
        request.entity = entity
        let fetchedProducts = try! managedObjectContext.fetch(request)
        for data in fetchedProducts as! [Providertable] {
            data.providerid = updateval
        }
        
        
        do {
            try managedObjectContext.save()
        } catch let error {
            print("Could not cache the response \(error)")
        }
    }

    
    
    func deleteUser(_ entityName: String) {
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        self.managedObjectContext = appDelegate.managedObjectContext
        let productEntity: NSEntityDescription = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)!
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetch.entity = productEntity
        
        let fetchedProducts: [AnyObject] = try! managedObjectContext.fetch(fetch)
        for data in fetchedProducts as! [Providertable] {
            managedObjectContext.delete(data)
        }
    }
}
