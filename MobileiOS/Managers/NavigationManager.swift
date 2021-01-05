//
//  NavigationManager.swift
//  MobileiOS
//
//  Created by George on 05/11/2020.
//

import UIKit

class NavigationManager{
    
//    var currentUserToken: String = ""
    
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
    
    func navigateToLoginViewController(currentViewController: UIViewController) {
        let loginViewController = currentViewController.storyboard?.instantiateViewController(withIdentifier: ViewControllerNames.loginViewController)
        currentViewController.view.window?.rootViewController = loginViewController
        currentViewController.view.window?.makeKeyAndVisible()
        
    }
    
    func navigateToTabBarController(currentViewController: UIViewController) {
        let homeViewController = currentViewController.storyboard?.instantiateViewController(withIdentifier: ViewControllerNames.tabbarController) as? UITabBarController
        currentViewController.view.window?.rootViewController = homeViewController
        currentViewController.view.window?.makeKeyAndVisible()
    }
    
    func navigateToCoordinatesViewController(currentViewController: UIViewController, itemId: String) {
        guard let coordinatesViewController = currentViewController.storyboard?.instantiateViewController(withIdentifier: ViewControllerNames.coordinatesViewController) as? CoordinatesViewController else { return }
        coordinatesViewController.itemId = itemId
        currentViewController.navigationController?.pushViewController(coordinatesViewController, animated: true)
    }
    
    func navigateToNavigationController2(currentViewController: UIViewController) {
        let navigationController2 = currentViewController.storyboard?.instantiateViewController(withIdentifier: ViewControllerNames.navigationController2) as? UINavigationController
        currentViewController.view.window?.rootViewController = navigationController2
        currentViewController.view.window?.makeKeyAndVisible()
    }
}
