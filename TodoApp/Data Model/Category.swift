//
//  Category.swift
//  TodoApp
//
//  Created by Cristian Costa on 17/09/2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    
    //Creamos relacion, cada categoria tiene muchos items
    let items = List<Item>()
}
