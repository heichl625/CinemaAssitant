//
//  RegisterViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 31/12/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signupBtn.layer.cornerRadius = signupBtn.frame.height / 2
        signupBtn.layer.borderColor = UIColor.white.cgColor
        signupBtn.layer.borderWidth = 2
        signupBtn.clipsToBounds = true
        
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
            
            if let e = error {
                
                let alertController = UIAlertController(title: "註冊失敗", message: "輸入的資料不符合規格", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "重新輪入", style: .default, handler: nil))
                self.present(alertController, animated: true)
                
            }else{
                let alertController = UIAlertController(title: "註冊成功", message: "你已成為Cinema Assistant的會員", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "好", style: .default, handler: { action in
                    Auth.auth().signIn(withEmail: username, password: password, completion: nil)
                    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "uid")
                    self.navigationController?.popToRootViewController(animated: true)
                    
                }))
                self.present(alertController, animated: true)
            }
        }
        
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
