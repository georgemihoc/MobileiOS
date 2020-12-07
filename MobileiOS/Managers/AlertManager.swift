//
//  AlertManager.swift
//  MobileiOS
//
//  Created by George on 28/10/2020.
//

import Foundation
import BRYXBanner

protocol ServiceDelegate {
    func redirectingImagePickerController(source: UIImagePickerController.SourceType)
}

class AlertManager {
    static let manager = AlertManager()
    
    private init() {}
    
    var delegate: ServiceDelegate?
    
    func showBannerNotification(title: String, message: String) {
        let banner = Banner(title:title, subtitle: message, backgroundColor: #colorLiteral(red: 0.2745098174, green: 0.5949271219, blue: 0.1411764771, alpha: 1))
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
    }
    
    func showDisconnectedBannerNotification(title: String, message: String, duration: Double) {
        let banner = Banner(title:title, subtitle: message, backgroundColor: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
        banner.dismissesOnTap = true
        banner.show(duration: duration)
    }
    
    func showAlert(currentViewController: UIViewController, message: String) {
        
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        currentViewController.present(alertController, animated: true, completion: nil)
    }
    
    func showGeneralAlert(currentViewController: UIViewController, title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        currentViewController.present(alertController, animated: true, completion: nil)
    }
    
    func showPhotoAlert(currentViewController: UIViewController) {
        let actionController = UIAlertController(title: "Add photo", message: nil, preferredStyle: .actionSheet)
        
        let cameraIcon = UIImage(systemName: "camera.fill")
        let takeAction = UIAlertAction(title: "Take photo", style: .default) {(_) in
            self.delegate?.redirectingImagePickerController(source: .camera)
        }
        takeAction.setValue(cameraIcon, forKey: "image")
        actionController.addAction(takeAction)
        
        
        let galleryIcon = UIImage(systemName: "photo.on.rectangle")
        let importAction = UIAlertAction(title: "Choose photo from library", style: .default) {(_) in
            self.delegate?.redirectingImagePickerController(source: .photoLibrary)
        }
        
        importAction.setValue(galleryIcon, forKey: "image")
        actionController.addAction(importAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionController.addAction(cancelAction)
        
        currentViewController.present(actionController, animated: true, completion: nil)
    }
}
