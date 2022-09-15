//
//  ViewController.swift
//  FireRecipeApp
//
//  Created by Francis Martin Fuerte on 9/12/22.
//a

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class LoginView: UIViewController, RecipeDBProtocol {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var recipeDB:RecipeDB?
    
    func ingredientsRetrieved(transaction: [Ingredients]) {
        //not used in this instance
    }
    
    func stepsRetrieved(transaction: [Steps]) {
        //not used in this instance
    }
    
    //gets the list of recipes
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
         
        //transition the list of recipes viewcontroller
        let recipeVC = storyboard!.instantiateViewController(withIdentifier: "RecipeView") as! RecipeTableView
        
        //set the data for the table
        recipeVC.sections = recipeSection
        
        self.navigationController!.pushViewController(recipeVC, animated: true)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        recipeDB = RecipeDB()
        recipeDB?.delegate = self
        
    }
    
    //handles create user button
    @IBAction func createUserPress(_ sender: Any) {
        let email = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
          if let error = error as? NSError {
              var message = ""
              
              switch AuthErrorCode.Code(rawValue: error.code) {
            case .operationNotAllowed: message = "Operation not allowed"
              // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
            case .emailAlreadyInUse: message = "Email already in use"
              // Error: The email address is already in use by another account.
            case .invalidEmail: message = "Invalid email"
              // Error: The email address is badly formatted.
            case .weakPassword: message = "Password must be 6 characters or more"
              // Error: The password must be 6 characters long or more.
            default:
                message = "Error: \(error.localizedDescription)"
            }
              //display alert for error
              let alert = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertController.Style.alert)
              alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: nil))
              self.present(alert, animated: true, completion: nil)
              
          } else {
              //created successfully
              
              //load the list of recipes
              self.recipeDB?.getRecipeList()
              
          }
            
        }
        usernameTextField.text = ""
        passwordTextField.text = ""
        
    }

    //handles login button
    @IBAction func loginPress(_ sender: Any) {
        
        let email = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
          if let error = error as? NSError {
              var message = ""
              switch AuthErrorCode.Code(rawValue: error.code) {
              case .operationNotAllowed: message = "Operation not allowed"
              // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
            case .userDisabled: message = "Account has been disabled"
              // Error: The user account has been disabled by an administrator.
            case .wrongPassword: message = "Password is invalid"
              // Error: The password is invalid or the user does not have a password.
            case .invalidEmail: message = "Email is invalid"
              // Error: Indicates the email address is malformed.
            default:
                  message = "Error: \(error.localizedDescription)"
            }
              //display alert for error
              let alert = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertController.Style.alert)
              alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: nil))
              self.present(alert, animated: true, completion: nil)
              
          } else {
              //logged in successfully
              
              //load list of recipes
              self.recipeDB?.getRecipeList()
          }
        }
        
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
}

