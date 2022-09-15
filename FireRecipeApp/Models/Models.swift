//
//  Models.swift
//  FireRecipeApp
//
//  Created by Francis Martin Fuerte on 9/13/22.
//

import Foundation

//model for the list of recipes
struct Recipe: Decodable, Identifiable {
    var id: String = ""
    var recipeName: String = ""
    var description: String = ""
    var categoryName: String = ""
    var createdBy: String = ""
}

//model for the list of ingredients
struct Ingredients: Decodable, Identifiable {
    var id: String = ""
    var ingredientsName: String = ""
    var quantity: String = ""
    var unitOfMeasure: String = ""
    var recipeID: String = ""
    var createdBy: String = ""
}

//model for the list of steps
struct Steps: Decodable, Identifiable {
    var id: String = ""
    var stepNumber: String = ""
    var stepDescription: String = ""
    var recipeID: String = ""
    var createdBy: String = ""
}
