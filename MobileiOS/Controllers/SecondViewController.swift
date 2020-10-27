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
    var handler: String = ""
    var data: String = ""
    var message: String = ""
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handlerLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textData = Symbols.detectSymbols(text: message)
        messageTextView.attributedText = textData
        
        nameLabel.text = name
        handlerLabel.text = handler
        dataLabel.text = data
    }
}
