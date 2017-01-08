//
//  ViewController.swift
//  GoodGirlOrBoy
//
//  Created by Simone on 1/2/17.
//  Copyright © 2017 Simone. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!

    private var controller: NSFetchedResultsController<Child>!
    
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Good Girl or Boy"
        
        let request: NSFetchRequest<Child> = Child.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Child.name), ascending: true)]
        
        controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        try! controller.performFetch()
    }
    
    //pop up controller
    @IBAction func addChild(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Child", message: "Enter child's information below", preferredStyle: .alert)
        let saveChild = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let savedName = textField.text else {
                    return
            }
            
            //create a method to save name
            self.save(name: savedName)
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        //        alert.addTextField()
        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Child's Name"
        }
        alert.addAction(saveChild)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
    }
    
    func save(name: String) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Child", in: managedContext)!
        let kid = NSManagedObject(entity: entity, insertInto: managedContext)
        kid.setValue(name, forKey: "name")
        
        do {
            
            if context.hasChanges {
                try! context.save()
            }
            //            children.append(kid)
            
        }
        //        catch let error as NSError {
        //            print("Could not save. \(error), \(error.userInfo)")
        //        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = controller.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let sections = controller.sections {
            //            return boys.count
            let info: NSFetchedResultsSectionInfo = sections[section]
            return info.numberOfObjects
        }
        return 0
    }
    
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //        let child = children[indexPath.row]
        
        //display name from NSManagedObjectContext using key-value coding
        //        cell.textLabel?.text = child.value(forKeyPath: "name") as? String
        
        let object = controller.object(at: indexPath)
        cell.textLabel?.text = object.value(forKey: "name") as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let object = controller.object(at: indexPath)
            context.delete(object)
            try! context.save()
        default:
            break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .update:
            tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
   
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "behaviorSegue" {
            let details = segue.destination as! SocialViewController
                guard let indexPath = tableView.indexPathForSelectedRow else {
                    fatalError("App misconfigured")
            }
            
            let socialEntryDetails = controller.object(at: indexPath)
            
            details.socialEntry = socialEntryDetails
            details.otherContext = socialEntryDetails.managedObjectContext
//            details.delegate = self
        }
    }
}

