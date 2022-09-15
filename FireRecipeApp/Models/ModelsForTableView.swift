//
//  ModelsForTableView.swift
//  FireRecipeApp
//
//  Created by Francis Martin Fuerte on 9/14/22.
//

import Foundation

//model of the recipe list table
public struct RecipeList {
    public var name: String
    public var description: String
    public var docID:String
    
    public init(_ name: String,_ description: String,_ docID: String) {
        self.name = name
        self.description = description
        self.docID = docID
    }
}

//model for the row info of the recipes
public struct RecipeSection {
    public var name: String
    public var items: [RecipeList]
    
    public init(name: String, items: [RecipeList]) {
        self.name = name
        self.items = items
    }
}


//model of the ingredients and steps table
public struct RecipeDetailList {
    public var display: String
    public var description: String
    public var sectionInfo: String
    public var quantity: String
    public var unitOfMeasure: String
    public var itemNumber: String
    public var createdBy: String
    
    
    public init(_ display: String,_ description: String, _ sectionInfo: String, _ quantity: String, _ unitOfMeasure: String, _ itemNumber:String, _ createdBy:String) {
        self.display = display
        self.description = description
        self.sectionInfo = sectionInfo
        self.quantity = quantity
        self.unitOfMeasure = unitOfMeasure
        self.itemNumber = itemNumber
        self.createdBy = createdBy
    }
}

//model for the row info of the ingredients and steps
public struct RecipeDetailSection {
    public var name: String
    public var items: [RecipeDetailList]
    
    public init(name: String, items: [RecipeDetailList]) {
        self.name = name
        self.items = items
    }
}
