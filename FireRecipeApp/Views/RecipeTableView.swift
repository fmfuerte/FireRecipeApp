//
//  CollapsibleTableView.swift
//  FireRecipeApp
//
//  Created by Francis Martin Fuerte on 9/14/22.
//

import Foundation
import UIKit
import CollapsibleTableSectionViewController
import Firebase
import FirebaseAuth


class RecipeTableView: CollapsibleTableSectionViewController, RecipeDBProtocol {
    
    var recipeDB:RecipeDB?
    var recipeID = ""
    
    //flag to know if the data has been loaded
    var loadedIngredients = false
    var loadedSteps = false

    //data for the recipe table
    var sections = [RecipeSection]()
    
    //data for the list of ingredients and steps when selected
    var ingredientsList = [RecipeDetailList]()
    var stepsList = [RecipeDetailList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeDB = RecipeDB()
        recipeDB?.delegate = self
        
       // recipeDB?.getStepsList("eT6DGBNDZhG11moutq8t")
      //  recipeDB?.getIngredientList("eT6DGBNDZhG11moutq8t")
       // recipeID = "eT6DGBNDZhG11moutq8t"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeTapped))
    }
    
    //handle auto logout when main page is closed
    deinit{
        print("out")
        do {
          try Auth.auth().signOut()
        } catch {
          print("Sign out error")
        }
    }
    
    @objc func addRecipeTapped(){
        let alertController = UIAlertController(title: "Add New Recipe", message: "", preferredStyle: .alert)

        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Recipe Name"
        }
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Description"
        }
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Category - Pork, Beef, Chicken, Seafood, Etc"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let recipeNameTextField = alertController.textFields![0] as UITextField
            let descriptionTextField = alertController.textFields![1] as UITextField
            let categoryTextField = alertController.textFields![2] as UITextField
            
            let tempRecipe = Recipe(id: UUID().uuidString,recipeName: recipeNameTextField.text ?? "" , description: descriptionTextField.text ?? "", categoryName: categoryTextField.text ?? "" , createdBy: Auth.auth().currentUser?.uid ?? "" )
            
            self.recipeDB?.saveRecipe(tempRecipe)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil )


        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func recipesRetrieved(transaction: [Recipe]) {
            //convert/process Recipe into RecipeSection (categoryName,Items)
            var porkList = [RecipeList]()
            var beefList = [RecipeList]()
            var chickenList = [RecipeList]()
            var seafoodList = [RecipeList]()
            var othersList = [RecipeList]()
            
            for recipe in transaction {
                switch (recipe.categoryName){
                case "Pork": porkList.append(RecipeList(recipe.recipeName,recipe.description, recipe.id))
                case "Beef": beefList.append(RecipeList(recipe.recipeName,recipe.description, recipe.id))
                case "Chicken": chickenList.append(RecipeList(recipe.recipeName,recipe.description, recipe.id))
                case "Seafood": seafoodList.append(RecipeList(recipe.recipeName,recipe.description, recipe.id))
                default: othersList.append(RecipeList(recipe.recipeName,recipe.description, recipe.id))
                }
            }
            
            //process the data and group by sections (category)
            var recipeSection = [RecipeSection]()
            
            recipeSection.append(RecipeSection(name: "Pork", items: porkList))
            recipeSection.append(RecipeSection(name: "Beef", items: beefList))
            recipeSection.append(RecipeSection(name: "Chicken", items: chickenList))
            recipeSection.append(RecipeSection(name: "Seafood", items: seafoodList))
            recipeSection.append(RecipeSection(name: "Others", items: othersList))
            
            self.sections = recipeSection
    }
    
    //loads the list of ingredients
    func ingredientsRetrieved(transaction: [Ingredients]) {
        //convert/process Ingredient to generic RecipeDetailList (for table display)
        var detailList = [RecipeDetailList]()
        
        for ingredients in transaction {
            detailList.append(RecipeDetailList((ingredients.quantity + " " + ingredients.unitOfMeasure), ingredients.ingredientsName, "Ingredients", ingredients.quantity, ingredients.unitOfMeasure, "", ingredients.createdBy))
        }
    
        //set to global ingredients list and update flag
        ingredientsList = detailList
        loadedIngredients = true

        //check if both ingredients and steps have been loaded
        if loadedIngredients == true && loadedSteps == true {
            //update the flag to false for the next run
            loadedSteps = false
            loadedIngredients = false
            
            //create a blank detail section (data for the detail table)
            var recipeSection = [RecipeDetailSection]()
            
            recipeSection.append(RecipeDetailSection(name: "Ingredients", items: ingredientsList))
            recipeSection.append(RecipeDetailSection(name: "Steps", items: stepsList))
            
            //open the detail viewcontroller
            let detailVC = storyboard!.instantiateViewController(withIdentifier: "DetailView") as! RecipeDetailsTableView
            
            //set the data for the table
            detailVC.sections = recipeSection
            detailVC.recipeID = recipeID
            
            self.navigationController!.pushViewController(detailVC, animated: true)
            
        }
       
        
    }
    
    //loads the list of steps
    func stepsRetrieved(transaction: [Steps]) {
        //convert/process steps to generic RecipeDetailList
        var detailList = [RecipeDetailList]()
        
        for steps in transaction {
            detailList.append(RecipeDetailList(steps.stepNumber, steps.stepDescription, "Steps", "", "", steps.stepNumber, steps.createdBy))
        }
    
        stepsList = detailList
        loadedSteps = true

        //check if both ingredient and steps have loaded
        if loadedIngredients == true && loadedSteps == true {
            
            //update the flag to false for the next run
            loadedSteps = false
            loadedIngredients = false
            
            //create a blank detail section (data for the detail table)
            var recipeSection = [RecipeDetailSection]()
            
            recipeSection.append(RecipeDetailSection(name: "Ingredients", items: ingredientsList))
            recipeSection.append(RecipeDetailSection(name: "Steps", items: stepsList))
            
            //open up the detail view
            let detailVC = storyboard!.instantiateViewController(withIdentifier: "DetailView") as! RecipeDetailsTableView
            
            //Set the data for the details table
            detailVC.sections = recipeSection
            detailVC.recipeID = recipeID
            
            self.navigationController!.pushViewController(detailVC, animated: true)
            
        }
       
    }
    
}

//handles the table
extension RecipeTableView: CollapsibleTableSectionDelegate {
    
    func numberOfSections(_ tableView: UITableView) -> Int {
        return sections.count
    }
    
    func collapsibleTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collapsibleTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomCell ??
            CustomCell(style: .default, reuseIdentifier: "Cell")
        
        let item: RecipeList = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = item.name
        cell.detailLabel.text = item.description
        
        return cell
    }
    
    //handles the action when a row is selection
    func collapsibleTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //get the recipe from the table
        let item: RecipeList = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        //load the list of steps and ingredients based on recipe ID
        recipeDB?.getStepsList(item.docID)
        recipeDB?.getIngredientList(item.docID)
        recipeID = item.docID
    }
    
    func collapsibleTableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    
    func collapsibleTableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    //sets sections to be collapsed (closed) as default
    func shouldCollapseByDefault(_ tableView: UITableView) -> Bool {
        return false
    }
    
}
