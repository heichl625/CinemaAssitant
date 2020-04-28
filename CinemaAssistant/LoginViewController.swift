//
//  LoginViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 31/12/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        // Do any additional setup after loading the view.
        loginBtn.layer.cornerRadius = loginBtn.frame.height / 2
        loginBtn.layer.borderColor = UIColor.white.cgColor
        loginBtn.layer.borderWidth = 2
        loginBtn.clipsToBounds = true
        
    }
    
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        
        Auth.auth().signIn(withEmail: username, password: password, completion: { authResults, error in
            
            if let e = error {
                
                let alertController = UIAlertController(title: "無法登入", message: "註冊電郵或密碼錯誤", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "重新輸入", style: .default, handler: nil))
                self.present(alertController, animated: true)
                
            }else{
                
                UserDefaults.standard.setValue(Auth.auth().currentUser?.uid, forKey: "uid")
                
                let alertController = UIAlertController(title: "成功登入", message: "已登入Cinema Assistant帳戶", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "好", style: .default, handler: { action in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alertController, animated: true)
                
            }
            
        })
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let error = error {
                print(error)
            }else{
                UserDefaults.standard.setValue(Auth.auth().currentUser?.uid, forKey: "uid")
                
                let alertController = UIAlertController(title: "成功登入", message: "已登入Cinema Assistant帳戶", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "好", style: .default, handler: { action in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alertController, animated: true)
                
            }
            
        }
    }
    
    @IBAction func googleBtnPressed(_ sender: UIButton) {
        
        GIDSignIn.sharedInstance().signIn()
        
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
