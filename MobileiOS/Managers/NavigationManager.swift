//
//  NavigationManager.swift
//  MobileiOS
//
//  Created by George on 05/11/2020.
//

import UIKit

class NavigationManager{
    
    static let manager = NavigationManager()
    
    private init() {}

    func navigateToMainScreen(currentViewController: UIViewController, user: User) {
        guard let mainViewControler = currentViewController.storyboard?.instantiateViewController(withIdentifier: ViewControllerNames.mainViewController) else { return }
        currentViewController.navigationController?.pushViewController(mainViewControler, animated: true)
    }
    
    func navigateToNavigationController(currentViewController: UIViewController) {
        let homeViewController = currentViewController.storyboard?.instantiateViewController(withIdentifier: ViewControllerNames.navigationController) as? UINavigationController
        currentViewController.view.window?.rootViewController = homeViewController
        currentViewController.view.window?.makeKeyAndVisible()
    }
}
