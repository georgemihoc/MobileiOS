//
//  SpinnerViewController.swift
//  NetworkingTask
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {
    
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    override func loadView() {
        view = UIView()
//        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        view.backgroundColor = UIColor(white: 0, alpha: 1)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
