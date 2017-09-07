//
//  ViewController.swift
//  Test
//
//  Created by Pranav Joshi on 30/3/17.
//  Copyright © 2017 Pranav Joshi. All rights reserved.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {

    
    @IBOutlet weak var signinSelector: UIStackView!
    
    @IBOutlet weak var signinLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    var isLogin:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginSelectorChanged(_ sender: UISegmentedControl) {
        
        isLogin = !isLogin //flip the boolean
        
        if isLogin{
            signinLabel.text = "Login"
            loginButton.setTitle("Login", for: .normal)
            
        }
        else{
            signinLabel.text = "Register"
            loginButton.setTitle("Register", for: .normal)
        }
        
    }
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        if let email = emailTextField.text, let pass = passwordTextField.text
        {
        
        
        if isLogin{
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                
                
                if user != nil {
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                }
                else {
                    
                }
                
                
            })
            
            
        }
        else{
            FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user, error) in
                
                FIRAuth.auth()?.currentUser?.sendEmailVerification( completion: { (error) in
                    // ...
                    print("sent email - pranav is gay")
                })
                
                if user != nil{
                    
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                    
                }
                else{
                    
                }
                
            })
        }
        }
        
        
        
        

    }

}

