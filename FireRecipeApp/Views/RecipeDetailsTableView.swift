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


class RecipeDetailsTableView: CollapsibleTableSectionViewController {
 //   @IBOutlet weak var titleLabel: UILabel!
   // @IBOutlet weak var tableView: UITableView!
    
   // var dataArray = [DetailsList]()
    var sections = [RecipeDetailSection]()
    var recipeID = ""
    var recipeDB:RecipeDB?

    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  recipeDB = RecipeDB()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDetailTapped))
    }
    
    @objc func addDetailTapped(){
        let alertSheetController = UIAlertController(title: "Select Type", message: "", preferredStyle: .actionSheet)
        
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil )
        

        alertSheetController.addAction(IngredientsAction)
        alertSheetController.addAction(cancelAction)
        
        self.present(alertSheetController, animated: true, completion: nil)
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
