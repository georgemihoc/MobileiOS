//
//  LoginViewController.swift
//  MobileiOS
//
//  Created by George on 05/11/2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
        let currentUser = User(id: "1", username: username, password: password)
        print(currentUser.username)
        guard let data = DatabaseManager.manager.loadJson() else { return }
        
        if data.users.contains(where: {$0.username == username && $0.password == password}) {
            NavigationManager.manager.navigateToNavigationController(currentViewController: self)
        } else {
            AlertManager.manager.showAlert(currentViewController: self, message: "Invalid user")
        }
    }
}
