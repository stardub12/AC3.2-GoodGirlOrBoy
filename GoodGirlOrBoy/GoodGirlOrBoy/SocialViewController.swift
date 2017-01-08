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
        positiveOrNegative.text = "Negative"
        
    }

    
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
                let entry = controller.object(at: indexPath)
                cell.textLabel?.text = "\(entry.action): \(entry.behavior)"
                cell.detailTextLabel?.text = "\(dateLabel.text)"

        return cell
    }
    
    
}