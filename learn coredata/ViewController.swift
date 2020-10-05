//
//  ViewController.swift
//  learn coredata
//
//  Created by Yulibar Husni on 05/10/20.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var productTable: UITableView!
    var products: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        productTable.delegate = self
        productTable.dataSource = self
        productTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    @IBAction func addProduct(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                  let nameToSave = textField.text else {
                return
            }
            self.save(name: nameToSave)
            self.productTable.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(name: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        guard let entity = NSEntityDescription.entity(forEntityName: "Product", in: managedContext) else {return}
        
        let product = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        product.setValue(name, forKey: "name")
        
        // 4
        do {
            try managedContext.save()
            products.append(product)
        } catch let error as NSError {
            print("Couldn't save. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // 1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Product")
        
        // 3
        do {
            products = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Couldn't fetch data. \(error), \(error.userInfo)")
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = products[indexPath.row]
        let cell = productTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = product.value(forKeyPath: "name") as? String
        return cell
    }
}


