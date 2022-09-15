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


class RecipeDetailsTableView: CollapsibleTableSectionViewController, RecipeDBProtocol{
   // var dataArray = [DetailsList]()
    var sections = [RecipeDetailSection]()
    var recipeID = ""
    var recipeDB:RecipeDB?
    
    //data for the list of ingredients and steps when selected
    var ingredientsList = [RecipeDetailList]()
    var stepsList = [RecipeDetailList]()
    
    //flag to know if the data has been loaded
    var loadedIngredients = false
    var loadedSteps = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        recipeDB = RecipeDB()
        recipeDB?.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDetailTapped))
    }
    
    @objc func addDetailTapped(){
        let alertSheetController = UIAlertController(title: "Select Type", message: "", preferredStyle: .actionSheet)
        
        //Action handler for adding Ingredients
        let IngredientsAction = UIAlertAction(title: "Ingredients", style: .default, handler: { alert -> Void in
            
            let alertController = UIAlertController(title: "Add New Ingredient", message: "", preferredStyle: .alert)

            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Ingredient Name"
            }
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Quantity"
            }
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Unit Of Measure"
            }

            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let ingredientsNameTextField = alertController.textFields![0] as UITextField
                let quantityTextField = alertController.textFields![1] as UITextField
                let unitOfMeasureTextField = alertController.textFields![2] as UITextField
                
                let tempIngredients = Ingredients(id: UUID().uuidString, ingredientsName: ingredientsNameTextField.text ?? "" , quantity: quantityTextField.text ?? "", unitOfMeasure: unitOfMeasureTextField.text ?? "" , recipeID: self.recipeID,createdBy: Auth.auth().currentUser?.uid ?? "" )
                
                self.recipeDB?.saveIngredient(tempIngredients)
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil )


            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)

            
        })
        
        //Action handler for adding Steps
        let StepsAction = UIAlertAction(title: "Steps", style: .default, handler: { alert -> Void in
            
            let alertController = UIAlertController(title: "Add New Steps", message: "", preferredStyle: .alert)

            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Step Number"
            }
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Description"
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let stepNumberTextField = alertController.textFields![0] as UITextField
                let stepDescriptionTextField = alertController.textFields![1] as UITextField
                
                let tempSteps = Steps(id: UUID().uuidString, stepNumber: stepNumberTextField.text ?? "" , stepDescription: stepDescriptionTextField.text ?? "", recipeID: self.recipeID,createdBy: Auth.auth().currentUser?.uid ?? "" )
                
                self.recipeDB?.saveStep(tempSteps)
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil )


            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)

            
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil )
        

        alertSheetController.addAction(IngredientsAction)
        alertSheetController.addAction(StepsAction)
        alertSheetController.addAction(cancelAction)
        
        self.present(alertSheetController, animated: true, completion: nil)
    }
    
    func recipesRetrieved(transaction: [Recipe]) {
        //not used here
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
            
        
            //set the data for the table
            self.sections = recipeSection
            
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
            
            //Set the data for the details table
            self.sections = recipeSection
            
            
        }
       
    }
    

}

//populate the table
extension RecipeDetailsTableView: CollapsibleTableSectionDelegate {

    func numberOfSections(_ tableView: UITableView) -> Int {
        return sections.count
    }
    
    func collapsibleTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collapsibleTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomDetailCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomDetailCell ??
        CustomDetailCell(style: .default, reuseIdentifier: "Cell")
        
        let item: RecipeDetailList = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = item.display
        cell.detailLabel.text = item.description
        
        return cell
    }
    
    //handles the action when a row is selected
    func collapsibleTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //
        let item: RecipeDetailList = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
    }
    
    func collapsibleTableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    
    func collapsibleTableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    //sets sections to be open by default (not collapsed)
    func shouldCollapseByDefault(_ tableView: UITableView) -> Bool {
        return false
    }
    
}
