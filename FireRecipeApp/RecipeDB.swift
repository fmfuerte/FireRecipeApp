//
//  RecipeDB.swift
//  FireRecipeApp
//
//  Created by Francis Martin Fuerte on 9/13/22.
//

import Foundation
import FirebaseFirestore

//protocol to process data needed
protocol RecipeDBProtocol {
    func recipesRetrieved(transaction:[Recipe])
    func ingredientsRetrieved(transaction:[Ingredients])
    func stepsRetrieved(transaction:[Steps])
}

//this is the database handler
class RecipeDB {
    
    var delegate:RecipeDBProtocol?
    
    //different listeners for recipes, steps, and ingredients
    var listener:ListenerRegistration?
    var listener2:ListenerRegistration?
    var listener3:ListenerRegistration?
    
    
    // Unregister database listener
    deinit {
        listener?.remove()
        listener2?.remove()
        listener3?.remove()
    }
    
    
    //gets the list of recipes
    func getRecipeList(){
        
        // Detach any listener
        listener?.remove()
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        let query:Query = db.collection("tblRecipe")
        
        //Start Query and add a listener
        self.listener = query.addSnapshotListener({ (snapshot, error) in
            
            if error == nil && snapshot != nil {
                    
                    var trans = [Recipe]()
               
                    // Parse documents into Recipe
                    for doc in snapshot!.documents {
                                                                         
                        let new = Recipe(id: doc.documentID,
                                        recipeName: doc["recipeName"] as! String,
                                        description: doc["description"] as! String,
                                         categoryName: doc["categoryName"] as! String)
                        
                        trans.append(new)
                    }
                
                    // Call the delegate and pass back the recipes in the main thread
                    DispatchQueue.main.async {
                        self.delegate?.recipesRetrieved(transaction: trans)
                    }
                
                }
            
        })
            
            
    }
    
    //Gets a list of all ingredients for a particular recipe
    func getIngredientList(_ docID:String){
        
        // Detach any listener
        listener2?.remove()
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        var query:Query = db.collection("tblIngredients")
        
        query = query.whereField("recipeID", isEqualTo: docID)
        
        //Start Query and add a listener
        self.listener2 = query.addSnapshotListener({ (snapshot, error) in
            
            if error == nil && snapshot != nil {
                    
                    var trans = [Ingredients]()
               
                
                    // Parse documents into Ingredients
                    for doc in snapshot!.documents {
                        
                        let new = Ingredients(id: doc.documentID,
                                        ingredientsName: doc["ingredientsName"] as! String,
                                        quantity: doc["quantity"] as! String,
                                        unitOfMeasure: doc["unitOfMeasure"] as! String,
                                        recipeID: doc["recipeID"] as! String
                        )
                        
                        trans.append(new)
                    }
                    // Call the delegate and pass back the ingredients in the main thread
                    DispatchQueue.main.async {
                        self.delegate?.ingredientsRetrieved(transaction: trans)
                    }
                }
            
        })
            
            
    }
    
    //Gets the list of steps for a particular Recipe
    func getStepsList(_ docID:String){
        
        // Detach any listener
        listener3?.remove()
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        var query:Query = db.collection("tblSteps")
    
        query = query.whereField("recipeID", isEqualTo: docID)
        
        //Start Query and add a listener
        self.listener3 = query.addSnapshotListener({ (snapshot, error) in
            
            if error == nil && snapshot != nil {
                    
                    var trans = [Steps]()
               
                
                    // Parse documents into Steps
                    for doc in snapshot!.documents {
                        
                        let new = Steps(id: doc.documentID,
                                        stepNumber: doc["stepNumber"] as! String,
                                        stepDescription: doc["stepDescription"] as! String,
                                        recipeID: doc["recipeID"] as! String)
                        
                        trans.append(new)
                    }
                    // Call the delegate and pass back the Steps in the main thread
                    DispatchQueue.main.async {
                        self.delegate?.stepsRetrieved(transaction: trans)
                    }
                }
            
        })
            
            
    }
    
    //Delete the recipe
    func deleteRecipe(_ new:Recipe) {
        
        let db = Firestore.firestore()
        db.collection("tblRecipe").document(new.id).delete()
        
    }
    
    //Delete the ingredient
    func deleteIngredient(_ new:Ingredients) {
        
        let db = Firestore.firestore()
        db.collection("tblIngredients").document(new.id).delete()
        
    }
    
    //Delete the step
    func deleteStep(_ new:Steps) {
        
        let db = Firestore.firestore()
        db.collection("tblSteps").document(new.id).delete()
        
    }
    
    //Create/update the recipe
    func saveRecipe(_ new:Recipe) {
        let db = Firestore.firestore()
        
        let ref = db.collection("tblRecipe").document(new.id)
        ref.setData(ConvertRecipeToDict(new))
        
        db.collection("tblRecipe").document(ref.documentID.description).updateData(["docID":ref.documentID.description])
    }
    
    //Create/update the ingredient
    func saveIngredient(_ new:Ingredients) {
        let db = Firestore.firestore()
        
        let ref = db.collection("tblIngredients").document(new.id)
        ref.setData(ConvertIngredientsToDict(new))
        
        db.collection("tblIngredients").document(ref.documentID.description).updateData(["docID":ref.documentID.description])
    }
    
    //Create/update the step
    func saveStep(_ new:Steps) {
        let db = Firestore.firestore()
        
        let ref = db.collection("tblSteps").document(new.id)
        ref.setData(ConvertStepsToDict(new))
        
        db.collection("tblSteps").document(ref.documentID.description).updateData(["docID":ref.documentID.description])
    }
    
    //convert the Recipe to dictionary
    func ConvertRecipeToDict(_ new:Recipe) -> [String:Any] {
        var dict = [String:Any]()
        
        dict["id"] = new.id
        dict["recipeName"] = new.recipeName
        dict["categoryName"] = new.categoryName
        dict["description"] = new.description
        dict["createdBy"] = new.createdBy
        
        return dict
    }
    
    //convert the Ingredients to dictionary
    func ConvertIngredientsToDict(_ new:Ingredients) -> [String:Any] {
        var dict = [String:Any]()
        
        dict["id"] = new.id
        dict["ingredientsName"] = new.ingredientsName
        dict["quantity"] = new.quantity
        dict["unitOfMeasure"] = new.unitOfMeasure
        dict["recipeID"] = new.recipeID
        dict["createdBy"] = new.createdBy
        
        return dict
    }
    
    //convert the Steps to dictionary
    func ConvertStepsToDict(_ new:Steps) -> [String:Any] {
        var dict = [String:Any]()
        
        dict["id"] = new.id
        dict["stepNumber"] = new.stepNumber
        dict["stepDescription"] = new.stepDescription
        dict["recipeID"] = new.recipeID
        dict["createdBy"] = new.createdBy
        
        return dict
    }
    
}
