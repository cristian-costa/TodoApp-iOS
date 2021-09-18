//
//  Item.swift
//  TodoApp
//
//  Created by Cristian Costa on 17/09/2021.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //Relacion inversa, cada item tiene asociada una unica categoria.
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
