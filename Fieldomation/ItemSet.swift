//
//  ItemSet.swift
//  Fieldomation
//
//  Created by Devin Rogers on 1/9/24.
//

import Foundation

@Observable class ItemSet {
    var itemSet : Set<String> = []
    
    func insert(str: String) {
        itemSet.insert(str)
    }
    
    func toString() -> String {
        return itemSet.description
    }
    
    func getSet() -> Set<String> {
        return itemSet
    }
}
