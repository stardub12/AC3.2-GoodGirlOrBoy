//
//  ViewController.swift
//  GoodGirlOrBoy
//
//  Created by Simone on 1/2/17.
//  Copyright © 2017 Simone. All rights reserved.
//

import UIKit
import CoreData

protocol SocialEntryDelegate {
    func didFinish(viewController: SocialViewController, didSave: Bool)
}


class SocialViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var controller: NSFetchedResultsController<Child>!
    
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    var socialEntry: Child?
    var delegate: SocialEntryDelegate?
    var otherContext: NSManagedObjectContext?
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var positiveOrNegative: UILabel!
    @IBOutlet weak var behaviorLabel: UILabel!
    @IBOutlet weak var childLogLabel: UILabel!
    @IBOutlet weak var socialPicker: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    
    let pickerData = ["Throwing", "Running in the house", "Sharing", "Clearing the table", "Finishing dinner", "Hitting", "Saying 'thank you' ", "Biting", "Apologizing", "Doing homework"]
    
    enum Action: String {
        case Throwing = "Throwing"
        case Running = "Running in the house"
        case Sharing = "Sharing"
        case Cleanliness = "Clearing the table"
        case Eating = "Finishing dinner"
        case Hitting = "Hitting"
        case Manners = "Saying 'thank you' "
        case Biting = "Biting"
        case Apologizing = "Apologizing"
        case Studying = "Doing homework"
    }
    
    /// command + option + forward slash to add documentation(description)
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigation
        title = socialEntry?.name
        //pickerView
        self.socialPicker.delegate = self
        self.socialPicker.dataSource = self
        //tableView
        self.tableView.delegate = self
        
        loadLabels()
        
        let request: NSFetchRequest<Child> = Child.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Child.date), ascending: false)]
        do {
            //create objects
            let object = Child(context: context)
            object.date = NSDate()
            try! context.save()
        }
        
        controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        //tell the controller to perform fetch
        controller.delegate = self
        
        try! controller.performFetch()
    }
    
    func loadLabels() {
        //date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        socialEntry?.date = NSDate()
        if let date = socialEntry?.date {
            let currentDate = dateFormatter.string(from: date as Date)
            dateLabel.text = "\(currentDate)"
        }
        
        //log label
        if let name = socialEntry?.name {
            childLogLabel.text = "Entries for \(name)"
        }
        
        //pickerView
        behaviorLabel.text = pickerData[0]
        
        //positiveOrNegative
        if (behaviorLabel.text == Action.Throwing.rawValue) || (behaviorLabel.text == Action.Biting.rawValue) || (behaviorLabel.text == Action.Hitting.rawValue) || (behaviorLabel.text == Action.Running.rawValue) {
            positiveOrNegative.text = "Negative"
        } else {
            positiveOrNegative.text = "Postitive"
        }
    }

    //This is the major functionality issue...
        @IBAction func saveButtonTapped(_ sender: UIButton) {
            print("save button tapped")
            let child = Child(context: context)
            child.action = behaviorLabel.text
            child.action = positiveOrNegative.text
            child.date = NSDate()
            try! context.save()

        }
    
    //MARK: - pickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        behaviorLabel.text = pickerData[row]
    }
 
    
    //MARK: - tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let sections = controller.sections {
            let info = sections[section]
            return info.numberOfObjects
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) 
//                let entry = controller.object(at: indexPath)
        
        //using the labels (instead of controller) so that data can appear in the tableview
                cell.textLabel?.text = "\(behaviorLabel.text!): \(positiveOrNegative.text!)"
                cell.detailTextLabel?.text = "\(dateLabel.text!)"

        return cell
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let object = controller.object(at: indexPath)
            context.delete(object)
            try! context.save()
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .update:
            tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
}
