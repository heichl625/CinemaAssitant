//
//  MeViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 3/4/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class MeViewController: UIViewController, GIDSignInDelegate {
    
    
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var orString: UILabel!
    @IBOutlet weak var loginWithString: UILabel!
    @IBOutlet weak var googleBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnInit()
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
                
                print("Login success")
                UserDefaults.standard.setValue(Auth.auth().currentUser?.uid, forKey: "uid")
                self.viewWillAppear(true)
                
            }
            
        }
    }
    
    func btnInit(){
        if let lBtn = loginBtn{
            lBtn.layer.cornerRadius = loginBtn.frame.height / 2
            lBtn.layer.borderColor = UIColor.white.cgColor
            lBtn.layer.borderWidth = 2
            
            
            if Auth.auth().currentUser == nil {
                
                
                lBtn.setTitle("Login", for: .normal)
                signupBtn.isHidden = false
                googleBtn.isHidden = false
                loginWithString.isHidden = false
                orString.isHidden = false
                
                signupBtn.layer.cornerRadius = signupBtn.frame.height / 2
                signupBtn.layer.borderColor = UIColor.white.cgColor
                signupBtn.layer.borderWidth = 2
                signupBtn.clipsToBounds = true
                signupBtn.setTitle("Sign up", for: .normal)
                
            }else{
                
                lBtn.setTitle("Log Out", for: .normal)
                
                lBtn.clipsToBounds = true
                signupBtn.isHidden = true
                googleBtn.isHidden = true
                loginWithString.isHidden = true
                orString.isHidden = true
                
                
            }
        }
        
        
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "showLoginFromMe", sender: self)
        }else{
            
            let alertController = UIAlertController(title: "登出", message: "你確定要登出嗎？", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "是的", style: .default, handler: { action in
                try! Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: "uid")
                self.btnInit()
            }))
            alertController.addAction(UIAlertAction(title: "否", style: .default, handler: nil))
            present(alertController, animated: true)
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
