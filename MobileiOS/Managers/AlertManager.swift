//
//  AlertManager.swift
//  MobileiOS
//
//  Created by George on 28/10/2020.
//

import Foundation
import BRYXBanner

class AlertManager {
    static let manager = AlertManager()
    
    private init() {}
    
    func showBannerNotification(title: String, message: String) {
        let banner = Banner(title:title, subtitle: message, backgroundColor: #colorLiteral(red: 0.2745098174, green: 0.5949271219, blue: 0.1411764771, alpha: 1))
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
    }
    
    func showDisconnectedBannerNotification(title: String, message: String) {
        let banner = Banner(title:title, subtitle: message, backgroundColor: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
        banner.dismissesOnTap = true
        banner.show(duration: 100)
    }
    
    func showAlert(currentViewController: UIViewController, message: String) {
        
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        currentViewController.present(alertController, animated: true, completion: nil)
    }
    
}
