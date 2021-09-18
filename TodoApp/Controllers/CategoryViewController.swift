//
//  ViewController.swift
//  TodoApp
//
//  Created by Cristian Costa on 17/09/2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    //Inicializamos access point realm database
    let realm = try! Realm()

    //Coleccion de resultados
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navbar doesnt exist")}
        let navBarColor = UIColor(hexString: "1D9BF6")
        let contrastColor = ContrastColorOf(navBarColor!, returnFlat: true)
        // first line will color the notch in iPhone X and later
        navBar.subviews[0].backgroundColor = navBarColor
        navBar.backgroundColor = navBarColor
        //applies on navigation and bar items
        navBar.tintColor = contrastColor
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
    }
    
    //MARK: - Add Button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            //what will happen once the user clicks the Add Item Button
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            self.save(category: newCategory)
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //nil coalescing operator
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categoryArray?[indexPath.row] {
            guard let categoryColour = UIColor(hexString: category.color) else {fatalError()}
            
            cell.textLabel?.text = category.name
            cell.backgroundColor = categoryColour
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        
        return cell
        
    }
    

    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    func save(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func loadCategory() {
        //autoupdate categories, fetch all objects and reaload tableView
        categoryArray = realm.objects(Category.self)
        
        //Datasource methods
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(category)
                })
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}

