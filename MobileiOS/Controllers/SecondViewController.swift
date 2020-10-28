//
//  SecondViewController.swift
//  NetworkingTask
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController{
    
    var name: String = ""
    var data: String = ""
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = name
        dateTextField.text = data
    }
}
