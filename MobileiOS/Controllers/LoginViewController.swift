//
//  LoginViewController.swift
//  MobileiOS
//
//  Created by George on 05/11/2020.
//

import UIKit
import Alamofire
import IHProgressHUD
import os

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let logger = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TOKEN ******************")
        print(Defaults.manager.getCurrentToken())
        if Defaults.manager.getCurrentToken() != "" {
//            NavigationManager.manager.navigateToNavigationController(currentViewController: self)
            DispatchQueue.main.async {
                NavigationManager.manager.navigateToNavigationController(currentViewController: self)
            }
            
        }
    }
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard
            let username = usernameTextField.text,
            let password = passwordTextField.text
        else {
            AlertManager.manager.showAlert(currentViewController: self, message: "Data must be valid")
            return
        }
//        let currentUser = User(id: "1", username: username, password: password)
        
        let parameters: [String: Any] = [
            "username": username,
            "password": password,
        ]
        IHProgressHUD.show()
//        Networking.shared.login(parameters: parameters, currentViewController: self)
//        IHProgressHUD.dismiss()
        AF.request(Constants.authApi, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                switch response.result {
                case .success(_):
                    IHProgressHUD.dismiss()
                    guard let jsonData = try? JSONDecoder().decode(JSONResponse.self, from: response.data!) else { return
                    }
                    guard let token = jsonData.token else {
                        AlertManager.manager.showAlert(currentViewController: self, message: "Invalid credentials")
                        return
                    }

                    self.logger.log("TOKEN: \(token)")
                    Defaults.manager.storeToken(token: token, username: username)
                    print("************************************************")
                    print(Defaults.manager.getCurrentToken())
                    print("************************************************")

                    NavigationManager.manager.navigateToNavigationController(currentViewController: self)
                case .failure(_):
                    IHProgressHUD.dismiss()
                    AlertManager.manager.showAlert(currentViewController: self, message: "Network error")
                }
            }
    }
}
