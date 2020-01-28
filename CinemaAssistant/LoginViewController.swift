//
//  LoginViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 31/12/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        Auth.auth().signIn(withEmail: username, password: password, completion: { authResults, error in
            
            if let e = error {
                
                let alertController = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true)
                
            }else{
                
                let alertController = UIAlertController(title: "Success", message: "Login Successful", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alertController, animated: true)
                
            }
            
        })
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
