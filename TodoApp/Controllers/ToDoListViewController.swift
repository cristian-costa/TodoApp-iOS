//
//  ToDoListViewController.swift
//  TodoApp
//
//  Created by Cristian Costa on 17/09/2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.color {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {fatalError("Navbar doesnt exist")}
            if let navBarColor = UIColor(hexString: colourHex) {
                let contrastColor = ContrastColorOf(navBarColor, returnFlat: true)
                // first line will color the notch in iPhone X and later
                navBar.subviews[0].backgroundColor = navBarColor
                navBar.backgroundColor = navBarColor
                //applies on navigation and bar items
                navBar.tintColor = contrastColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
                
                searchBar.barTintColor = navBarColor
                searchBar.searchTextField.backgroundColor = .white
            }
        }
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            //activate or desactivate checkMark, ternary condition
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //what will happen once the user clicks the Add Item Button
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write({
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    })
                } catch {
                    print("Error \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(item)
                })
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
}

//MARK: - Search bar methods
extension ToDoListViewController: UISearchBarDelegate {
    //Busqueda en searchbar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    //Mostrar todos los items en tableview cuando la searchbar no tenga caracteres
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            //Ocultar keyboard.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
